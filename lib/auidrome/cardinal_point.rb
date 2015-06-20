# Copyright 2015 The Cocktail Experience
module Auidrome
  class CardinalPoint
    @@cardinal_points = {}
    @@letters_hash = {
      S:  'south',
      SE: 'southeast',
      E:  'east',
      NE: 'northeast',
      N:  'north',
      NW: 'northwest',
      W:  'west',
      SW: 'southwest'
    }

    # Drift should be N, S, W, E, NW, NE, SW or SE.
    def initialize drift
      @drift = drift.upcase.to_sym
    end

    def drift; config_values[0]; end # i.e. "N"
    def point; config_values[1]; end # i.e. "Human"
    def dromename; config_values[2]; end # i.e. "lovedrome"

    def drome_config
      @drome_config ||= Auidrome::Config.drome_config(dromename)
    end

    def point_class
      @point_class = if Module.const_defined?("Auidrome::#{point}")
        "Auidrome::#{point}".constantize
      else
        self
      end
    end

    def dromes
      if point_class == self
        [dromename]
      else
        point_class.dromes
      end
    end

    private
    def config_values
      # 0:    N-Human-lovedrome
      @config_values ||= self.class.cardinal_points_ports.values.detect {|str|
        str =~ /^#{@drift}\-/
      }.split('-')
    end

    class << self
      def for_letter(letter)
        @@cardinal_points[letter.upcase.to_sym] ||= new(letter)
      end
  
      def letter_to_word(letter)
        @@letters_hash[letter.upcase.to_sym]
      end
  
      # Returns array with [DRIFT, POINT, DROMENAME]
      def create_from_port_number(port_base)
        string = if port_base < 10000
          cardinal_points_ports[port_base] || cardinal_points_ports[0]
        else
          cardinal_points_ports[port_base.div(10000)]
        end
        new string.split('-')[0]
      end
  
      def cardinal_points_ports
        @@cardinal_points_ports ||= YAML.load_file('config/drome_cardinal_points.yml')
      end
  
      private
      def from_dromes *dromes
        {}.tap do |people|
          dromes.each do |drome|
            JSON.parse(File.read("data/public/#{drome}/tuits.json")).each do |name, created_at|
              people[name.to_sym] ||= []
              people[name.to_sym].push drome
            end
          end
        end
      end
    end
  end
end
