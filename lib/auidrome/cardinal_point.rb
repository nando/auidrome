# Copyright 2015 The Cocktail Experience
module Auidrome
  class CardinalPoint
    # Drift should be N, S, W, E, NW, NE, SW or SE.
    def initialize drift
      @drift = drift.upcase.to_sym
    end

    # Function to get 'south' from 's', 'north' from 'n', and so on...
    def self.letter_to_word(letter)
      case letter.upcase.to_sym
      when :S  then 'south'
      when :SE then 'southeast'
      when :E  then 'east'
      when :NE then 'northeast'
      when :N  then 'north'
      when :NW then 'northwest'
      when :W  then 'west'
      when :SW then 'southwest'
      else nil
      end
    end

    # Returns array with [DRIFT, POINT, DROMENAME]
    def self.create_from_port_number(port_base)
      string = if port_base < 10000
        cardinal_points_ports[port_base] || cardinal_points_ports[0]
      else
        cardinal_points_ports[port_base.div(10000)]
      end
      new string.split('-')[0]
    end

    def self.cardinal_points_ports
      @@cardinal_points_ports ||= YAML.load_file('config/drome_cardinal_points.yml')
    end

    def drift; config_values[0]; end
    def point; config_values[1]; end
    def dromename; config_values[2]; end

    def drome_config
      @drome_config ||= Auidrome::Config.load_drome(dromename)
    end

    private
    def config_values
      @config_values ||= self.class.cardinal_points_ports.values.detect {|str|
        str =~ /^#{@drift}\-/
      }.split('-')
    end
  end
end
