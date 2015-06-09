# Copyright 2015 The Cocktail Experience
require 'json'
require_relative 'cardinal_point'

module Auidrome
  # "auidos" in committed public/tuits.json on "human" dromes (with port number < 10000)
  class Document < CardinalPoint
    class << self
      @@all = nil

      # Returns a hash with :auido_as_symbol => [:array, :of, :dromenames]
      # For example:
      #  {
      #    :SEMANTIC_VERSIONING => [:notedrome, :docudrome],
      #    :HijackingFREEsoftware => [:notedrome]
      #  }
      def all
        # Order matters: the former more important when calling #drome_config_for(doc)
        @@all ||= from_dromes \
          :docudrome,
          :notedrome
      end
    end
  end
end
