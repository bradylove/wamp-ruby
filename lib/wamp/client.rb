require 'faye/websocket'
require 'json'
require 'eventmachine'

module WAMP
  class Client
    include WAMP::Bindable

    attr_accessor :id, :socket, :wamp_protocol, :server_ident, :topics, :callbacks,
                  :prefixes, :ws_server

    # WAMP Client
    #   Connects to WAMP server, after connection client should receve WELCOME message
    #   from server.
    #   Client can then register prefix, call, subscribe, unsubscribe, and publish

    def initialize(options = {})
      @ws_server = options[:host] || "ws://localhost:9000"
      @protocols = options[:protocols]
      @headers = options[:headers]
      @id     = nil
      @socket = nil
      @wamp_protocol = nil
      @server_ident  = nil

      @prefixes  = {}
      @topics    = []
      @callbacks = {}
    end

    def available_bindings
      [:connect, :welcome, :call_result, :call_error, :event, :disconnect]
    end

    def start
      EM.run do
        ws = Faye::WebSocket::Client.new(ws_server, @protocols, {:headers => @headers})

        ws.onopen    = lambda { |event| handle_open(ws, event) }
        ws.onmessage = lambda { |event| handle_message(event) }
        ws.onclose   = lambda { |event| handle_close(event) }
      end
    end

    def prefix(prefix, topic_uri)
      socket.send [WAMP::MessageType[:PREFIX], prefix, topic_uri].to_json

      prefixes[prefix] = topic_uri
    end

    def subscribe(topic_uri)
      socket.send [WAMP::MessageType[:SUBSCRIBE], topic_uri].to_json

      topics << topic_uri
    end

    def unsubscribe(topic_uri)
      socket.send [WAMP::MessageType[:UNSUBSCRIBE], topic_uri].to_json

      topics.delete(topic_uri)
    end

    def publish(topic_uri, payload, options = {})
      exclude = options.fetch(:exclude, nil)
      include = options.fetch(:include, nil)

      socket.send [WAMP::MessageType[:PUBLISH], topic_uri, payload, exclude, include].to_json
    end

    def stop
      EM.stop
    end

  private

    def handle_open(websocket, event)
      @socket = websocket

      trigger(:connect, self)
    end

    def handle_message(event)
      parsed_msg = JSON.parse(event.data)
      msg_type   = parsed_msg[0]

      case WAMP::MessageType[msg_type]
      when :WELCOME
        handle_welcome(parsed_msg)
      when :EVENT
        handle_event(parsed_msg)
      else
        handle_unknown(parsed_msg)
      end
    end

    # Handle welcome message from server
    # WELCOME data structure [0, CLIENT_ID, WAMP_PROTOCOL, SERVER_IDENTITY]
    def handle_welcome(data)
      @id            = data[1]
      @wamp_protocol = data[2]
      @server_ident  = data[3]

      trigger(:welcome, self)
    end

    # Handle an event message from server
    # EVENT data structure [8, TOPIC, PAYLOAD]
    def handle_event(data)
      topic   = data[1]
      payload = data[2]

      trigger(:event, self, topic, payload)
    end

    def handle_unknown(data)
      # Do nothing
    end

    def handle_close(event)
      socket = nil
      id     = nil

      trigger(:disconnect, self)
    end
  end
end
