# Copyright 2015 The Cocktail Experience
require 'stream'
module Auidrome
  class ActivityStream
    class << self
      def actor
        ENV['AUIDROME_STREAM_ACTOR']
      end
  
      def configured?
        (actor && !actor.empty?) || false
      end

      def client
        @@client ||= Stream::Client.new(ENV['STREAM_KEY'], ENV['STREAM_SECRET']) if configured?
      end
  
      def stream
        @@stream ||= client.feed('auidrome', actor) if configured?
      end

      def get(page = 0)
        if configured?
          @@last_response = ActivityStream.stream.get({
            offset: ACTIONS_PER_PAGE * page,
            limit: ACTIONS_PER_PAGE
          })
          @@last_response['results']
        end
      rescue Net::OpenTimeout, Stream::StreamApiResponseException => e
        @@last_response = {
          'exception' => e,
          'results' => [],
          'next' => ''
        }
        @@last_response['results']
      end

      def results
        read_from_last_response 'results'
      end

      def next
        read_from_last_response 'next'
      end

      def exception
        read_from_last_response 'exception'
      end
  
      def error?
        !exception.nil?
      end

      def bad_configuration?
        exception and exception.kind_of?(Stream::StreamApiResponseException)
      end

      def tuit!(tuit)
        if actor and client
          puts "ActivityStream.tuit! '#{tuit.auido}'"
          activity = activity_hash(:tuit, tuit, {
            target: tuit.config.dromename,
            when: tuit.created_at,
            foreign_id: tuit.created_at.to_i
          })
          stream.add_activity activity
        end
      end

      def amadrinate!(tuit)
        if actor and client
          puts "ActivityStream.amadrinate! '#{tuit.auido}'"
          activity = activity_hash(:amadrinate, tuit, {
            target: "#{tuit.config.dromename}:#{tuit.created_at.to_i}",
            when: Time.now
          })
          stream.add_activity activity
        end
      end

      private
      def activity_hash(verb, tuit, details)
        {
          actor: actor,
          verb: verb,
          tuit: tuit.auido,
          time: details[:when].iso8601,
          object: tuit.self_url,
          target: details[:target],
          foreign_id: details[:foreign_id]
        }
      end

      def read_from_last_response(key)
        if configured? and class_variables.include? :@@last_response
          @@last_response[key]
        end
      end
    end
  end
end
