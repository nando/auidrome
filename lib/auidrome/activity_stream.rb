# Copyright 2015 The Cocktail Experience
require 'stream'
module Auidrome
  class ActivityStream
    class << self
      def actor
        ENV['AUIDROME_STREAM_ACTOR']
      end
  
      def client
        @@client ||= Stream::Client.new(ENV['STREAM_KEY'], ENV['STREAM_SECRET'])
      end
  
      def stream
        @@stream ||= client.feed('auidrome', actor)
      end
  
      def tuit!(tuit)
        if actor and client
          puts "ActivityStream.tuit! '#{tuit.auido}'"
          activity = activity_hash(:tuit, tuit, {
            target: tuit.conf.dromename,
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
            target: 'this',
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
          object: tuit.tuit_url, #TODO: Redesign to avoid this tuit/drome mess!
          target: details[:target],
          foreign_id: details[:foreign_id]
        }
      end
    end
  end
end
