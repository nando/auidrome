# Copyright 2015 The Cocktail Experience
require 'json'
require 'time'
require_relative 'activity_stream.rb'
module Auidrome
  class Drome
    include Auidrome
    class << self
      def update_graph_nodes!(config)
        Neo4jServerDB.start_session!
        Tuit.stored_tuits.each do |auido, timestamp|
          puts "Uptading graph node for #{auido}..."
          Neo4jServerDB.create_node! Tuit.new(auido, config)
        end
      end

      def update_graph_relationships!(config)
        Neo4jServerDB.start_session!
        Tuit.stored_tuits.each do |auido, timestamp|
          puts "Uptading #{auido} node relationships..."
          Neo4jServerDB.update_node_relationships! Tuit.new(auido, config)
        end
      end
    end
  end
end
