# Copyright 2015 The Cocktail Experience, S.L.
require 'yaml'
require 'uri'

module Auidrome
  class Config
    @@configs = {} # Auidrome::Config instances of each drome.
    # Class instance variables "naming": @@HASH-KEYS_HASH-VALUE
    @@properties_drome = {} # Each property name with its mapped drome.
    @@values_config = {} # Values could be mapped too (i don't like this at all:(
    @@dromes_properties = {} # Properties for each dromename
    @@ports_drome = {} # Drome for each port

    def initialize(dromename = :auidrome, base_domain = 'localhost')
      puts "Auidrome::Config.new(#{dromename}, #{base_domain})"
      @yaml = YAML.load_file("config/dromes/#{dromename}.yml")
      @dromename = dromename
      @@dromename ||= dromename
      @@base_domain ||= base_domain
    end

    def method_missing(method, *args, &block)
      if self.class.respond_to?(method)
        self.class.send method
      else
        @yaml[method.to_s] || super
      end
    end

    def dromename
      @dromename
    end

    def drome_of_humans?
      @yaml['port_base'] < 10001
    end

    def cardinal_point
      @cardinal_point ||= CardinalPoint.create_from_port_number(@yaml['port_base'])
    end

    def pretty_json?
      File.exists? 'config/generate_pretty_json'
    end

    def domain_and_port
      @@base_domain + ":" + @yaml['port_base'].to_s
    end

    def url
      "http://#{domain_and_port}/"
    end

    def create_tuit! auido
      tuit = Tuit.create!(auido, self)
      ActivityStream.tuit! tuit
      Neo4jServerDB.create_node! tuit
    end

    def url_for(auido)
      "#{url}/tuits/#{URI.encode(auido)}"
    end

    class << self
      def dromes
        load_dromes_with_mappings
        @@configs
      end
  
      def drome_urls
        @@drome_urls ||= {}.tap do |urls_hash|
          dromes.each do |name, drome|
            urls_hash[name] = drome.url
          end
        end
      end
  
      def property_to_drome
        @@property_to_drome ||= {}.tap do |p2d|
          Config.properties_with_drome.each do |property, drome|
            p2d[property] = drome.dromename
          end
        end
      end
  
      def drome_config(name = nil)
        load_drome(name || @@dromename)
      end
  
      def pedalodrome
        load_drome :pedalodrome
      end
  
      def drome_mapping_for name, value
        if property_names_with_associated_drome.include?(name)
          # "value" can refine the drome selection
          drome_for_value(value.to_sym) || drome_for_property(name)
        end
      end
  
      def properties_with_drome
        property_names_with_associated_drome.each do |property|
          drome_for_property property
        end
        @@properties_drome
      end
  
      def property_names_with_associated_drome
        load_properties_from_mappings_file if @@properties_drome.empty?
        @@properties_drome.keys
      end
  
      def drome_for_property(name)
        if @@properties_drome[name].is_a? Auidrome::Config
          @@properties_drome[name]
        else
          @@properties_drome[name] = load_drome(@@properties_drome[name])
        end
      end
  
      def properties_mapped_to dromename
        load_properties_from_mappings_file
        @@dromes_properties[dromename.to_sym]
      end
  
      def drome_for_port port_base
        load_properties_from_mappings_file
        @@ports_drome[port_base.to_i]
      end

      def protocol_for property
        PROTOCOLS[property.downcase] || 'http://'
      end

      protected
      def load_dromes_with_mappings
        load_properties_from_mappings_file if @@configs.size == 0
      end
  
      def load_properties_from_mappings_file
        drome_property_mappings_file.each {|drome, property_names|
          @@dromes_properties[drome.to_sym] = []
          property_names.split(',').map(&:to_sym).each {|prop|
            @@dromes_properties[drome.to_sym] << prop
            @@properties_drome[prop] = drome
            @@ports_drome[load_drome(drome).port_base] = drome
          }
        }
      end
  
      def drome_property_mappings_file
        @drome_property_mappings_file ||= YAML.load_file('config/drome_property_mappings.yml')
      end

      def drome_for_value(value)
        if @@values_config[value].is_a? Auidrome::Config
          @@values_config[value]
        elsif conf = People.drome_config_for(value.to_sym)
          @@values_config[value] = conf
        end
      end

      def load_drome dromename
        @@configs[dromename.to_sym] ||= new(dromename, @@base_domain)
      end
    end
  end
end
