require 'json'

module WAMP
  class Socket
    attr_accessor :id, :websocket, :topics, :prefixes

    def initialize(id, websocket)
      @id        = id
      @topics    = []
      @prefixes  = {}
      @websocket = websocket

      send_welcome_message
    end

    def add_topic(topic)
      topics << topic unless topics.include? topic
    end

    def remove_topic(topic)
      topics.delete(topic)
    end

    def add_prefix(prefix, uri)
      prefixes[prefix] = uri
    end

    def to_json
      {
        id:       id,
        topics:   topics,
        prefixes: prefixes
      }.to_json
    end

    private

    def send_welcome_message
      welcome_msg = [WAMP::MessageType[:WELCOME], id, WAMP.protocol_version, WAMP.identity]
      # websocket.send welcome_msg.to_json
    end
  end
end
