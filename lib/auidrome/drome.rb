# Copyright 2015 The Cocktail Experience
require 'json'
require 'time'
require_relative 'activity_stream.rb'
module Auidrome
  class Drome
    include Auidrome

    attr_reader :conf

    def initialize config = nil
      @conf = config || Config.new
      @hash = Tuit.empty_tuit
    end

    def hash
      @hash
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

    def create_tuit auido, timestamp
      Tuit.create! auido, timestamp
      @hash.merge! Tuit.read_from_index_file(auido)
      ActivityStream.tuit! self 
      Neo4jServerDB.create_node! self
    end

    def update_graph_nodes!
      Neo4jServerDB.start_session!
      Tuit.current_stored_tuits.each do |tuit, timestamp|
        puts "Uptading graph node for #{tuit}..."
        @hash = Tuit.read_from_index_file(tuit)
        Neo4jServerDB.create_node! self
      end
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

    def auido_href
      # CAUTION: It could be NIL!!! (we need at least a point between letters)
      if @hash[:web] && !web.empty? # Checking before asking
        web =~ /^http/ ? web : "http://#{web}"
      else
        "http://#{@hash[:auido]}" if @hash[:auido] =~ /.+\..+/ # DOES IT HAS A POINT?
      end
    end

    def self.protocol_for property
      PROTOCOLS[property.downcase] || 'http://'
    end

    # embedded value
    def embeddable_property?(property, value)
      value =~ /^<.+>$/ or
      PROPERTY_VALUE_TEMPLATES[:embeddings].include?(property.to_sym)
    end

    def embed_for(property, value)
      PROPERTY_VALUE_TEMPLATES[:embeddings][property].gsub('{{value}}', value)
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
      elsif drome = Config.drome_mapping_for(name_sym, value)
        "#{Drome.protocol_for(name)}#{drome.domain_and_port}/tuits/#{value}"
      else
        "#{Drome.protocol_for(name)}#{value}"
      end
    end

    def image_src
      if @hash[:auido] and image_file?
        @image_file
      else
        "/images/common/#{conf.dromename}.png"
      end
    end

    def image_href
      if better_image?
        "/tuits" + "/better" * (image_quality + 1) + "/#{@hash[:auido]}"
      else
        "/tuits/#{@hash[:auido]}"
      end
    end

    def image_class
      image_quality == 0 ? 'img-thumbnail' : 'img-normal'
    end

    def better_image?
      !(image_of_quality(image_quality+1)).nil?
    end

    #TODO: Me suena que Ruby tiene algo para hacer esto mejor (pero no me acuerdo :(
    def enumerable(property)
      val = self.send(property)
      if val.is_a? Enumerable
        val
      else
        [val]
      end
    end

    def save_json!
      save_hash_in_tuits_file! basic_jsonld_for(@hash[:auido]).merge(@hash)
    end

    def basic_jsonld_for auido
      {
        :'@context' => conf.url + "json-context.json",
        :'@id' => tuit_url
      }.merge(Tuit.basic_data_for(auido))
    end

    def tuit_url
      conf.url + "tuits/#{@hash[:auido]}"
    end

    def image_quality
      @quality ||= 0
    end   

    def load_json auido, reader = nil, quality = 0
      @quality = quality # Currently only for image quality ("better" subdir levels)
      @hash = Tuit.new(auido, reader).hash
      self
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

    def show_property_name(name)
      # Done thanks to Bozhidar Ivanov's post "Using Ruby's Gsub With a Block"
      #   (http://batsov.com/articles/2013/08/30/using-gsub-with-a-block/)
      name.to_s.gsub(/{{(.+)}}/) {
        human_auido = Regexp.last_match[1]
        if drome = People.drome_for(human_auido)
          %!<a href="#{drome.url}/tuits/#{human_auido}">#{human_auido}</a>!
        else
          human_auido
        end
      }
    end

    def created_at
      if created_at = @hash[:created_at]
        created_at.is_a?(String) ? Time.parse(created_at) : created_at
      end
    end

    def tuit_id
      created_at.to_i
    end

    private
    def image_file?
      @image_file = image_of_quality(image_quality) unless @image_file
      !@image_file.nil?
    end

    def image_of_quality quality
      prefix = quality > 0 ? "#{(['better']*quality).join('/')}/" : ""
      basepath = "/images/#{prefix}" + @hash[:auido] 
      %w{gif jpeg jpg png}.each do |extension|
        filepath = "#{basepath}.#{extension}"
        return filepath if File.exists?("public" + filepath)
      end
      return nil
    end

    def save_hash_in_tuits_file! hash
      File.open(PUBLIC_TUITS_DIR + "/#{hash[:auido]}.json","w") do |f|
        if @conf.pretty_json?
          f.write JSON.pretty_generate(hash)
        else
          f.write hash.to_json
        end
      end
    end

  end
end
