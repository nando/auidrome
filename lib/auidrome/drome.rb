# Copyright 2015 The Cocktail Experience
require 'json'
require 'time'
require_relative 'activity_stream.rb'
module Auidrome
  class Drome
    include Auidrome
    def initialize(config)
      @config = config
    end

    def create_tuit! auido, timestamp
      tuit = Tuit.create!(auido, timestamp)
      ActivityStream.tuit! tuit
      Neo4jServerDB.create_node! tuit
    end

    def update_graph_nodes!
      Neo4jServerDB.start_session!
      Tuit.current_stored_tuits.each do |tuit, timestamp|
        puts "Uptading graph node for #{tuit}..."
        Tuit.read_from_index_file(tuit)
        Neo4jServerDB.create_node! self
      end
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

    def self.protocol_for property
      PROTOCOLS[property.downcase] || 'http://'
    end

  end
end
