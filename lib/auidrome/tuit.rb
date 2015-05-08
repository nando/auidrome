# Copyright 2015 The Cocktail Experience
require 'json'
module Auidrome
  class Tuit
    #TODO: This smells very bad... all of them are class methods!
    class << self
      def empty_tuit
        {
          auido: nil,
          created_at: nil,
          identity: [],
          madrino: []
        }
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
        empty_tuit.merge!({
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
