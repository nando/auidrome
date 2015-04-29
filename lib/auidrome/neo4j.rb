# Copyright 2015 The Cocktail Experience
require 'neo4j'
module Auidrome
  class Neo4jServerDB
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
        run_query create_query(tuit)
      end

      def update_property!(tuit, property)
        if Config.property_names_with_associated_drome.include?(property)
          related_auidos = [tuit.send(property)].flatten
          related_auidos.each do |related_auido|
            run_query update_mapped_property_value_query(tuit, property, related_auido)
          end
        elsif tuit.unmapped_properties.include?(property)
          run_query update_unmapped_property_query(tuit, property)
        end
      end

      def update_unmapped_properties!(tuit)
        run_query update_unmapped_properties_query(tuit)
      end

      private
      def node_labels_for(tuit)
        "#{tuit.conf.cardinal_point.point}:#{tuit.conf.dromename.capitalize}"
      end

      def create_query(tuit)
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

      def update_mapped_property_value_query(tuit, property, related_auido)
        related_cp = Config.drome_for_property(property).cardinal_point
        relationship = property.to_s.downcase.gsub(' ', '_')
        <<-QUERY
          MATCH (a:#{tuit.conf.cardinal_point.point}),(b:#{related_cp.point})
          WHERE a.name =~ '(?i)#{tuit.auido}' AND b.name =~ '(?i)#{related_auido}'
          CREATE UNIQUE (a)-[r:#{relationship}]->(b)
          RETURN r
        QUERY
      end

      def update_unmapped_property_query(tuit, property)
        <<-QUERY
          MATCH (e {id: '#{tuit.tuit_id}'})
          SET e.#{property}="#{tuit.send(property).to_s.gsub('"','\"')}"
        QUERY
      end

      def update_unmapped_properties_query(tuit)
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

