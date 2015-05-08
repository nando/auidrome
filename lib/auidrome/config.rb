# Copyright 2015 The Cocktail Experience
require 'yaml'
module Auidrome
  class Config
    @@dromes = {} # Auidrome::Config instances of each drome.
    # Class instance variables "naming": @@HASH-KEYS_HASH-VALUE
    @@properties_drome = {} # Each property name with its mapped drome.
    @@values_drome = {} # Values could be mapped too (i don't like this at all:(
    @@dromes_properties = {} # Properties for each dromename
    @@ports_drome = {} # Drome for each port

    def initialize cfg_file=nil
      puts "LOADING DROME CONFIGURATION FILE (#{cfg_file})"
      cfg_file ||= "config/dromes/auidrome.yml"
      cfg_file = "config/dromes/#{cfg_file.downcase}.yml" unless cfg_file =~ /^config.+yml$/
      @yaml = YAML.load_file(cfg_file)
      @dromename = File.basename(cfg_file, '.yml').to_sym
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

    def self.dromes
      self.load_dromes_with_mappings
      @@dromes
    end

    def self.drome dromename
      load_drome dromename.to_sym
    end

    def self.pedalodrome
      load_drome :pedalodrome
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
      App.settings.base_domain + ":" + @yaml['port_base'].to_s
    end

    def url
      "http://#{domain_and_port}/"
    end

    def self.drome_mapping_for name, value
      if property_names_with_associated_drome.include?(name)
        # "value" can refine the drome selection
        drome_for_value(value.to_sym) || drome_for_property(name)
      end
    end

    def self.properties_with_drome
      property_names_with_associated_drome.each do |property|
        drome_for_property property
      end
      @@properties_drome
    end

    def self.property_names_with_associated_drome
      load_properties_from_mappings_file if @@properties_drome.empty?
      @@properties_drome.keys
    end

    def self.drome_for_property(name)
      if @@properties_drome[name].is_a? Auidrome::Config
        @@properties_drome[name]
      else
        @@properties_drome[name] = load_drome(@@properties_drome[name])
      end
    end

    def self.properties_mapped_to dromename
      load_properties_from_mappings_file
      @@dromes_properties[dromename.to_sym]
    end

    def self.drome_for_port port_base
      load_properties_from_mappings_file
      @@ports_drome[port_base.to_i]
    end

    protected
    def self.load_dromes_with_mappings
      self.load_properties_from_mappings_file if @@dromes.size == 0
    end

    def self.load_properties_from_mappings_file
      drome_property_mappings_file.each {|drome, property_names|
        @@dromes_properties[drome.to_sym] = []
        property_names.split(',').map(&:to_sym).each {|prop|
          @@dromes_properties[drome.to_sym] << prop
          @@properties_drome[prop] = drome
          @@ports_drome[load_drome(drome).port_base] = drome
        }
      }
    end

    def self.drome_property_mappings_file
      @drome_property_mappings_file ||= YAML.load_file('config/drome_property_mappings.yml')
    end

    def self.drome_for_value(value)
      if @@values_drome[value].is_a? Auidrome::Config
        @@values_drome[value]
      elsif drome = People.drome_for(value.to_sym)
        @@values_drome[value] = drome
      end
    end

    def self.load_drome dromename
      @@dromes[dromename.to_sym] ||= new("config/dromes/#{dromename}.yml")
    end
  end
end
