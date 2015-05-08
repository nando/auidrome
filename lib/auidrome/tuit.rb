# Copyright 2015 The Cocktail Experience
require 'json'
module Auidrome
  class Tuit
    attr_reader :hash

    def initialize(auido, reader)
      public_data = self.class.read_json("#{PUBLIC_TUITS_DIR}/#{auido}.json")
      protected_data = if AccessLevel.can_read_protected?(reader, public_data)
        self.class.read_json("#{PROTECTED_TUITS_DIR}/#{auido}.json")
      else
        {}
      end
      private_data = if AccessLevel.can_read_private?(reader, public_data)
        self.class.read_json("#{PRIVATE_TUITS_DIR}/#{auido}.json")
      else
        {}
      end

      @hash = self.class.basic_data_for(auido).merge(public_data.merge(protected_data.merge(private_data)))
    end

    class << self
      def empty_tuit
        {
          auido: nil,
          created_at: nil,
          identity: [],
          madrino: []
        }
      end

      def basic_data_for auido
        @hash = read_from_index_file(auido).merge(@hash)
      end

      def current_stored_tuits
        @@stored_tuits ||= tuits_in_index_file
      end
  
      def exists? tuit
        current_stored_tuits.keys.include? tuit.to_sym
      end
  
      def read_from_index_file auido
        created_at = if string = Tuit.current_stored_tuits[auido.to_sym]
          Time.parse(string)
        else
          #TODO: this should be "nil", because this tuits hasn't been created yet.
          # (i'm afraid to return nil right now and have no time at this moment...:(
          Time.now.utc
        end
        @hash = empty_tuit.merge!({
          auido: auido,
          created_at: created_at
        })
      end
  
      def read_json(filepath)
        File.exists?(filepath) ? JSON.parse(File.read(filepath), symbolize_names: true) : {}
      end
  
      def create! tuit, timestamp
        @@stored_tuits[tuit] = timestamp.to_s # the same as if it're read from JSON file
        Tuit.store_tuits!
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
