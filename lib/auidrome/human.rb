# Copyright 2015 The Cocktail Experience
require 'json'
require_relative 'cardinal_point'

module Auidrome
  # "auidos" in committed public/tuits.json on "human" dromes (with port number < 10000)
  class Human < CardinalPoint
    class << self
      @@all = nil
      @@pedalers = {}

      # Returns a hash with :auido_as_symbol => [:array, :of, :dromenames]
      # For example:
      #  {
      #    :alejandroporras => [:byebyedrome, :pedalodrome],
      #    :olalla => [:acadodrome, :auidrome]
      #  }
      def all
        # Order matters: the former more important when calling #drome_config_for(person)
        @@all ||= from_dromes \
          :auidrome,
          :byebyedrome,
          :pedalodrome,
          :acadodrome,
          :restodrome,
          :lovedrome,
          :ripodrome,
          :fictiondrome,
          :repulsodrome
      end


      def drome_config_for auido
        Auidrome::Config.drome_config(all[auido.to_sym].first) if all[auido.to_sym]
      end

      # Returns a hash with the Twitter identities of the people in the
      # Pedalodrome associated with their name. For example:
      #   { :ander_r4 => :ANDER, ... }
      def pedalers
        if @@pedalers.empty?
          Dir.glob("#{PEDALERS_DIR}/*.json") do |path|
            auido = File.basename(path, '.json')
            identities = JSON.parse(File.read(path))['identity'] || []
            identities.each do |identity|
              @@pedalers[identity.to_sym] = auido.to_sym
            end
          end
        end
        @@pedalers
      end
    end
  end
end
