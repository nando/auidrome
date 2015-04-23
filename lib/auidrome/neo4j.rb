# Copyright 2015 The Cocktail Experience
require 'neo4j'
module Auidrome
  class Neo4J
    class << self
      def server
        ENV['AUIDROME_NEO4J_SERVER']
      end

      def configured?
        (server && !server.empty?) || false
      end

      def open_session
        if configured?
          @@neo4j_session ||= Neo4j::Session.open(:server_db, server)
        end
      end

      def create_node(tuit)
        run_query create_query_for(tuit)
      end

      def update_unmapped_properties(tuit)
        run_query update_unmapped_query_for(tuit)
      end

      private
      def node_labels_for(tuit)
        "#{tuit.conf.point}:#{tuit.conf.dromename.capitalize}"
      end

      def create_query_for(tuit)
        node_labels = node_labels_for(tuit)
        node_properties = <<-PROPERTIES
            {
              id: "#{tuit.tuit_id}",
              name: "#{tuit.auido}",
              iso8601: "#{tuit.created_at.iso8601}"
            }
        PROPERTIES
        <<-QUERY_STRING
          \nMATCH (
            entry:#{node_labels}\n#{node_properties}
          \n) WITH COUNT(*) AS entries
          \nWHERE entries = 0 CREATE (new:#{node_labels}\n#{node_properties});
        QUERY_STRING
      end

      def update_unmapped_query_for(tuit)
        <<-QUERY
          MATCH (e { id: '#{tuit.tuit_id}' })
          SET #{tuit.unmapped_properties.map{|p| %!e.#{p}="#{tuit.send(p).to_s.gsub('"','\"')}"!}.join(', ')}
        QUERY
      end

      def run_query(query)
        if configured?
          puts query #TODO: the logging thing (this line sucks!)
          Neo4j::Session.current.query query
        end
      end

    end
  end
end

