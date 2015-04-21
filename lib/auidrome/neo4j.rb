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
        if configured?
          query = create_query_for(tuit)
          puts query #TODO: the logging thing...
          Neo4j::Session.current.query query
        end
      end

      private
      def create_query_for(tuit)
        node_labels = "#{tuit.conf.point}:#{tuit.conf.dromename.capitalize}"
        node_properties = <<-PROPERTIES
            {
              name: "#{tuit.auido}",
              id: "#{tuit.tuit_id}",
              created_at: "#{tuit.created_at.iso8601}"
            }
        PROPERTIES

        <<-QUERY_STRING
          MATCH (
            entry:#{node_labels}
            #{node_properties}
          ) WITH COUNT(*) AS entries
          WHERE entries = 0 CREATE (new:#{node_labels} #{node_properties});
        QUERY_STRING
      end
    end
  end
end

