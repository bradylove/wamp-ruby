require 'redis'
require 'json'

module WAMP
  module Engines
    class Redis < Memory
      attr_accessor :clients, :topics

      DEFAULT_HOST     = 'localhost'
      DEFAULT_PORT     = 6379
      DEFAULT_DATABASE = 0
      DEFAULT_GC       = 60
      LOCK_TIMEOUT     = 120

      # Creates a new instance of the Redis engine and sets up the connections
      # to the Redis server
      def initialize(options)
        super

        @host      = options[:host]     || DEFAULT_HOST
        @port      = options[:port]     || DEFAULT_PORT
        @database  = options[:database] || DEFAULT_DATABASE
        @gc        = options[:gc]       || DEFAULT_GC
        @password  = options[:password]
        @namespace = options[:namespace] || ''

        @clients_ns  = @namespace + ":clients"
        @topics_ns   = @namespace + ":topics"
        @prefixes_ns = @namespace + ":prefixes"
        @events_ns   = @namespace + ":events"

        @completed_events = []

        @redis      = ::Redis.new(host: @host, port: @port)
        @subscriber = ::Redis.new(host: @host, port: @port)

        if @password
          @redis.auth(@password)
          @subscriber.auth(@password)
        end

        @redis.select(@database)
        @subscriber.select(@database)

        redis_subscribe_to_events
      end

      def create_event(client, topic_uri, payload, excluded, included)
        redis_create_event(client.id, topic_uri, protocol, payload, excluded, included)
      end

    private

      def redis_subscribe_to_events
        Thread.new do
          @subscriber.subscribe(@events_ns) do |on|
            on.message do |channel, message|
              redis_handle_message(message)
            end
          end
        end
      end

      def redis_handle_message(message)
        begin
          id, client_id, topic_uri, payload, excluded, included = JSON.parse(message)

          client = find_clients(id: client_id).first
          topic  = find_or_create_topic(topic_uri)

          topic.publish(client, protocol, payload, excluded, included) if topic
        rescue => e
          puts e
        end
      end

      def redis_create_event(client_id, topic_uri, protocol, payload, excluded, included)
        @redis.publish @events_ns, [random_uuid, client_id, topic_uri, payload, excluded, included].to_json
      end
    end
  end
end
