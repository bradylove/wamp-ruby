require 'securerandom'

module WAMP
  module Engines

    # Engine for managing clients, and topics in system memory. This engine is
    # best used for single servers.
    class Memory
      attr_reader :clients, :topics, :options

      # Creates a new instance of the memory engine as well as some empty hashes
      # for holding clients and topics.
      # @param options [Hash] Optional. Options hash for the memory engine.
      def initialize(options = {})
        @options = options
        @clients = {}
        @topics  = {}
      end

      # Creates a new Socket object and adds it as a client.
      # @param websocket [WebSocket] The websocket connection that belongs to the
      #   new client
      # @return [WebSocket] Returns the newly created socket object
      def create_client(websocket)
        client = new_client(websocket)
        @clients[client.id] = client
      end

      # Finds clients by the given parameters. Currently only supports one
      #   parameter. Todo: Support multiple parameters.
      # @param args [Hash] A hash of arguments to match against the given clients
      # @return [Array] Returns an array of all matching clients.
      def find_clients(args = {})
        matching_clients = clients.find_all do |id, socket|
          socket.send(args.first[0]) == args.first[1]
        end

        matching_clients.flat_map { |x| x[1] }
      end

      # Deletes a client
      # @param socket [WebSocket] The websocket to remove from clients
      # @return [WAMP::Socket] The client that was removed
      def delete_client(websocket)
        client = find_clients(websocket: websocket).first

        clients.delete client.id
      end

      # Returns an array of all connected clients
      # @return [Array] Array of all connected clients.
      def all_clients
        clients.values
      end

      # Finds an existing topic, if non is found it will create one.
      # @param topic_uri [String] The URI for the topic to find or create.
      # @return [WAMP::Topic] Returns a WAMP Topic object.
      def find_or_create_topic(topic_uri)
        @topics[topic_uri] ||= new_topic(topic_uri)
      end

      # Add a client to a topic and a topic to a client
      # @param client [WAMP::Socket] The client socket to subscribe to the topic.
      # @param topic_uri [String] URI or CURIE the client is to subscribe to.
      # @return [WAMP::Topic] The topic that the client subscribed to.
      def subscribe_client_to_topic(client, topic_uri)
        topic = find_or_create_topic(topic_uri)

        client.add_topic(topic)
        topic.add_client(client)

        topic
      end

      # Remove a client from a topic.
      # @param client [WAMP::Socket] The client socket to unsubscribe from the topic.
      # @param topic_uri [String] The URI of the topic to unsubscribe from.
      # @return [WAMP::Topic] The topic that the client unsubscribed from.
      def unsubscribe_client_from_topic(client, topic_uri)
        topic = find_or_create_topic(topic_uri)

        client.remove_topic(topic)
        topic.remove_client(client)

        topic
      end

      def create_event(client, topic_uri, payload, exclude, include)
        topic = find_or_create_topic(topic_uri)

        topic.publish(client, protocol, payload, exclude, include) if topic
      end

      private

      def protocol
        WAMP::Protocols::Version1.new
      end

      def new_client(websocket)
        WAMP::Socket.new(random_uuid, websocket)
      end

      def new_topic(uri)
        WAMP::Topic.new(uri)
      end

      def random_uuid
        SecureRandom.uuid
      end
    end
  end
end
