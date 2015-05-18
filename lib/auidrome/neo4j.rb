# Copyright 2015 The Cocktail Experience
require 'neo4j'
require 'babosa'

module Auidrome
  class Neo4jServerDB
    class << self
      def server
        ENV['AUIDROME_NEO4J_SERVER']
      end

      def configured?
        (server && !server.empty?) || false
      end

      def start_session!
        if configured?
          @@neo4j_session ||= Neo4j::Session.open(:server_db, server)
        else
          'WARNING: Neo4j server NOT configured (AUIDROME_NEO4J_SERVER env. var is empty)'
        end
      end

      def session
        @@neo4j_session
      end

      def create_node!(tuit)
        run_query create_query(tuit)
      end

      def update_node_relationships!(tuit)
        puts "Updating #{tuit.auido}'s relationships (#{tuit.other_properties.join(',')}):"
        tuit.other_properties.each do |prop|
          update_property! tuit, prop
        end
      end

      def update_property!(tuit, property)
        printf "  * Updating #{tuit.auido}'s #{property} property..."
        if Config.property_names_with_associated_drome.include?(property)
          puts "mapped property!"
          related_auidos = [tuit.send(property)].flatten
          related_auidos.each do |related_auido|
            run_query update_mapped_property_value_query(tuit, property, related_auido)
          end
        elsif tuit.unmapped_properties.include?(property)
          puts "unmapped property."
          run_query update_unmapped_property_query(tuit, property)
        end
      end

      def update_unmapped_properties!(tuit)
        run_query update_unmapped_properties_query(tuit)
      end

      private
      def create_query(tuit)
        node_labels = "#{tuit.config.cardinal_point.point}:#{tuit.config.dromename.capitalize}"
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
          MATCH (a:#{tuit.config.cardinal_point.point}),(b:#{related_cp.point})
          WHERE a.name =~ #{to_query_value('(?i)'+tuit.auido.to_s)} AND b.name =~ #{to_query_value('(?i)'+related_auido)}
          CREATE UNIQUE (a)-[r:#{relationship}]->(b)
          RETURN r
        QUERY
      end

      def update_unmapped_property_query(tuit, property)
        <<-QUERY
          MATCH (e {id: '#{tuit.tuit_id}'})
          SET e.#{to_query_key(property)}=#{to_query_value(tuit.send(property))}
        QUERY
      end

      def update_unmapped_properties_query(tuit)
        <<-QUERY
          MATCH (e { id: '#{tuit.tuit_id}' })
          SET #{tuit.unmapped_properties.map{|p| %!e.#{to_query_key(p)}="#{to_query_value(tuit.send(p))}"!}.join(', ')}
        QUERY
      end

      def run_query(query)
        if configured? and session
          puts query #TODO: the logging thing (this line sucks!)
          session.query query
          Neo4j::Session.current.query query
        elsif configured?
          puts 'WARNING: Neo4j server configured but no session yet:(please, call #start_session! first:)'
        end
      end

      def to_query_key(name)
        name.to_s.to_slug.transliterate.to_s.gsub(/[0-9 \/\-!\.'"{},ºª:¿?]/, '_')
      end

      def to_query_value(value)
        # Double quoted with double quotes escaped
        %!"#{value.to_s.gsub('"','\"')}"!
      end
    end
  end
end

