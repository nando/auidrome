# Copyright 2015 The Cocktail Experience, S.L.
require 'json'
require 'babosa'

module Auidrome
  class Tuit
    attr_reader :hash
    attr_reader :reader
    attr_reader :config

    def initialize(auido, config = nil, reader = nil)
      @config ||= (config || Auidrome::Config.new)
      @reader = reader

      filename =  Tuit.name_for_files(auido)

      @hash = Tuit.basic_data_for(auido, filename).merge \
        json_url: "#{@config.url}tuits/#{filename}.json"

      public_data = Tuit.read_json(PUBLIC_TUITS_DIR, filename)
      protected_data = if reader && AccessLevel.can_read_protected?(reader, public_data)
        Tuit.read_json(PROTECTED_TUITS_DIR, filename)
      else
        {}
      end
      private_data = if reader && AccessLevel.can_read_private?(reader, public_data)
        Tuit.read_json(PRIVATE_TUITS_DIR, filename)
      else
        {}
      end
      @hash.merge! public_data.merge(protected_data.merge(private_data))
    end

    def filename
      @hash[:filename]
    end

    def json_url
      @hash[:json_url]
    end

    def identity
      @hash[:identity]
    end

    def madrino
      @hash[:madrino]
    end

    def properties
      @hash.keys
    end

    def values
      @hash.values
    end

    def method_missing(method, *args, &block)
      @hash[method.to_sym] || super
    end

    def core_properties
      CORE_PROPERTIES # no more, no less, by now...
    end

    def other_properties
      @other_properties ||= properties - CORE_PROPERTIES
    end

    def unmapped_properties
      @unmapped_properties ||= other_properties - Config.property_names_with_associated_drome
    end

    def auido
      @hash[:auido]
    end

    def link_outside
      # CAUTION: It could be NIL!!! (we need at least a point between letters)
      if href = (@hash[:url] || @hash[:web]) and !href.empty?
        href =~ /^http/ ? href : "http://#{href}"
      elsif @hash[:auido] =~ /.+\..+/ # DOES IT HAS A POINT?
        # ...then the "auido" is the URL itself
        "http://#{@hash[:auido]}"
      end
    end

    def basic_jsonld
      {
        :'@context' => @config.url + "json-context.json",
        :'@id' => self_url
      }.merge(Tuit.basic_data_for(@hash[:auido], @hash[:filename]))
    end

    def save_json!
      @hash[:updated_at] = Time.now.utc.to_s
      json = basic_jsonld.merge(@hash)
      File.open(PUBLIC_TUITS_DIR + "/#{@hash[:filename]}.json","w") do |f|
        f.write JSON.pretty_generate(basic_jsonld.merge(@hash))
      end
    end

    def add_value! property, value
      if @hash[property] and @hash[property].is_a?(Array)
         @hash[property] << value
      elsif @hash[property]
         @hash[property] = [@hash[property], value]
      else
         @hash[property] = value
      end
      save_json!

      Neo4jServerDB.update_property! self, property
    end

    def add_identity! user
      @hash[:identity] << user unless @hash[:identity].include? user
      save_json!
    end

    def add_madrino! user
      @hash[:madrino] << user unless @hash[:madrino].include? user
      save_json!
    end

    def created_at
      if created_at = @hash[:created_at]
        created_at.is_a?(String) ? Time.parse(created_at) : created_at
      end
    end

    def tuit_id
      created_at.to_i
    end

    def self_url
      "#{@config.url}tuits/#{URI.encode(@hash[:auido].to_s)}"
    end

    private

    class << self
      def empty_tuit_hash
        {
          auido: nil,
          created_at: nil,
          identity: [],
          madrino: []
        }
      end

      def basic_data_for auido, filename
        created_at = if string = stored_tuits[auido.to_sym]
          Time.parse(string)
        else
          #TODO: this should be "nil", because this tuits hasn't been created yet.
          # (i'm afraid to return nil right now and have no time at this moment...:(
          Time.now.utc
        end
        empty_tuit_hash.merge!({
          created_at: created_at,
          auido: auido,
          transliterated: transliterated(auido),
          # Old tuits are not transliterated...
          filename: filename # ...to know how it's been stored.
        })
      end

      def stored_tuits
        @@stored_tuits ||= tuits_in_index_file
      end
 
      def exists? tuit
        stored_tuits.keys.include? tuit.to_sym
      end

      def has_avatar? tuit
        TuitImage.has_avatar? tuit
      end
 
      def read_json(dir, filename)
        filepath = "#{dir}/#{filename}.json"
        File.exists?(filepath) ? JSON.parse(File.read(filepath), symbolize_names: true) : {}
      end

      def transliterated(string_or_symbol)
        string_or_symbol.to_s.to_slug.transliterate(:spanish).to_s.downcase
      end
  
      def name_for_files(auido)
        json_filepath = "#{PUBLIC_TUITS_DIR}/#{auido}.json"
        if File.exists?(json_filepath) or TuitImage.has_images?(auido)
          auido
        else
          transliterated(auido)
        end
      end
  
      def create! tuit, config
        @@stored_tuits[tuit] = Time.now.utc.to_s # the same as if it're read from JSON file
        store_tuits!
        new tuit, config
      end
  
      # to <a href> value
      def hrefable_property? property, value
        HREF_PROPERTIES.include?(property) or
        PROPERTY_VALUE_TEMPLATES[:hrefs].include?(property.to_sym) or
        Config.property_names_with_associated_drome.include?(property.to_sym) or
        value =~ /^https?:\/\//i
      end
 
      def href_for name, value
        name_sym = name.downcase.to_sym
        if value =~ /^https?:/i
          value
        elsif template = PROPERTY_VALUE_TEMPLATES[:hrefs][name_sym]
          template.gsub('{{value}}', value)
        elsif mapped_drome = Config.drome_mapping_for(name_sym, value)
          "#{Config.protocol_for(name)}#{mapped_drome.domain_and_port}/tuits/#{value}"
        else
          "#{Config.protocol_for(name)}#{value}"
        end
      end

      # embedded value
      def embeddable_property?(property, value)
        value =~ /^<.+>$/ or
        PROPERTY_VALUE_TEMPLATES[:embeddings].include?(property.to_sym)
      end
  
      def embed_for(property, value)
        PROPERTY_VALUE_TEMPLATES[:embeddings][property].gsub('{{value}}', value)
      end


      private
      def store_tuits!
        File.open(TUITS_FILE,"w") do |f|
          f.write JSON.pretty_generate(@@stored_tuits)
        end 
      end
  
      def tuits_in_index_file
        if File.file?(TUITS_FILE)
          JSON.parse(File.read(TUITS_FILE), symbolize_names: true)
        else
          {}
        end
      end
    end
  end
end
