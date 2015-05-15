# Copyright 2015 The Cocktail Experience
require 'json'
require 'time'
require_relative 'activity_stream.rb'
module Auidrome
  class Drome
    include Auidrome
    class << self
      def update_graph_nodes!
        Neo4jServerDB.start_session!
        Tuit.current_stored_tuits.each do |tuit, timestamp|
          puts "Uptading graph node for #{tuit}..."
          Tuit.read_from_index_file(tuit)
          Neo4jServerDB.create_node! self
        end
      end
    end
  end
end
