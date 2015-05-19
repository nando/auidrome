# Copyright 2015 The Cocktail Experience
require 'json'
module Auidrome
  class Search
    class << self
      def searchable_regexp
        /[\w ÁÉÍÓÚÑÜ¿?¡!':.-]+/
      end

      def searchable_text? str
        str =~ searchable_regexp
      end
    
      def pretty_json_line_regexp # to catch:
                                  #  - $1: the dromename
                                  #  - $2: the matched entry name
                                  #  - $3: the moment when was first submitted
        /public\/(\w+)\/tuits\.json:  \"(#{searchable_regexp})\": \"([^"]+)/
      end
    end

    attr_reader :dromename
    attr_reader :query
    attr_reader :conf
    attr_reader :results

    def initialize(query, config = nil)
      @query = query
      @results = grep_search_for(query)
      @conf = config || Auidrome::Config.new
      @dromename = @conf.dromename
    end

    def in_other_dromes
      @in_other_dromes ||= {}.tap do |others|
        (@results.keys - [@dromename]).each do |other|
          others[other] = {
            number_of_auidos: @results[other].length,
            search_url: Config.drome_config(other).url + "search?query=" + @query
          }
        end
      end
    end

    def payload
      {
        '@context' => conf.url + "json-context.json",
        '@id' => conf.url + "search?query=#{@query}",
        query: @query,
        results: @results[@dromename] || {},
        in_other_dromes: in_other_dromes
      }
    end

    private
    def grep_search_for(text)
      {}.tap do |res| 
        puts "rgrep #{text} data/public/*/tuits.json"
        `rgrep #{text} data/public/*/tuits.json`.each_line do |line|
          if line =~ self.class.pretty_json_line_regexp
            drome, auido, at = $1.to_sym, $2, $3
            res[drome] ||= {}
            res[drome][auido] = at
          end
        end
      end
    end
  end
end
