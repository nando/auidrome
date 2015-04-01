# Copyright 2015 The Cocktail Experience
require 'json'
module Auidrome
  class Tuit
    def self.current_stored_tuits
      @@stored_tuits ||= tuits_in_index_file
    end

    def self.exists? tuit
      current_stored_tuits.keys.include? tuit.to_sym
    end

    def self.read_from_index_file auido
      {
        auido: auido,
        created_at: Tuit.current_stored_tuits[auido.to_sym] || Time.now.utc
      }
    end

    def self.read_json(filepath)
      File.exists?(filepath) ? JSON.parse(File.read(filepath), symbolize_names: true) : {}
    end

    def self.create! tuit, timestamp
      @@stored_tuits[tuit] = timestamp
      Tuit.store_tuits!
    end

    private
    def self.store_tuits!
      File.open(TUITS_FILE,"w") do |f|
        f.write JSON.pretty_generate(@@stored_tuits)
      end 
    end

    def self.tuits_in_index_file
      if File.file?(TUITS_FILE)
        JSON.parse(File.read(TUITS_FILE), symbolize_names: true)
      else
        {}
      end
    end
  end
end
