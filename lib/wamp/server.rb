require 'faye/websocket'
require 'json'

module WAMP
  class Server
    include WAMP::Bindable

    attr_accessor :options, :topics, :callbacks, :engine

    def initialize(options = {})
      @options   = options
      @options[:engine] ||= {}
      @options[:engine][:type] ||= :memory

      @topics    = {}
      @callbacks = {}
      @engine    = WAMP::Engines.const_get(camelize(@options[:engine][:type])).new(@options[:engine])
      @protocol  = WAMP::Protocols::Version1.new
    end

    def available_bindings
      [:subscribe, :unsubscribe, :publish, :call, :prefix, :connect, :disconnect]
    end

    def start
      lambda do |env|
        Faye::WebSocket.load_adapter('thin')
        if Faye::WebSocket.websocket?(env)
          ws = Faye::WebSocket.new(env, ['wamp'], ping: 25)

          ws.onopen    = lambda { |event| handle_open(ws, event) }
          ws.onmessage = lambda { |event| handle_message(ws, event) }
          ws.onclose   = lambda { |event| handle_close(ws, event) }

          ws.rack_response
        else
          # Normal HTTP request
          [200, {'Content-Type' => 'text/plain'}, ['Hello']]
        end
      end
    end

  private

    def camelize(str)
      str.to_s.split('_').map {|w| w.capitalize}.join
    end

    def handle_open(websocket, event)
      client = @engine.create_client(websocket)
      client.websocket.send @protocol.welcome(client.id)

      trigger(:connect, client)
    end

    def handle_message(websocket, event)
      client = @engine.find_clients(websocket: websocket).first

      data     = JSON.parse(event.data)
      msg_type = data.shift

      case WAMP::MessageType[msg_type]
      when :PREFIX
        handle_prefix(client, data)
      when :CALL
        handle_call(client, data)
      when :SUBSCRIBE
        handle_subscribe(client, data)
      when :UNSUBSCRIBE
        handle_unsubscribe(client, data)
      when :PUBLISH
        handle_publish(client, data)
      end
    end

    # Handle a prefix message from a client
    # PREFIX data structure [PREFIX, URI]
    def handle_prefix(client, data)
      prefix, uri = data

      topic = @engine.find_or_create_topic(uri)
      client.add_prefix(prefix, topic)

      trigger(:prefix, client, prefix, uri)
    end

    # Handle RPC call message from a client
    # CALL data structure [callID, procURI, ... ]
    def handle_call(client, data)
      call_id, proc_uri, *args = data

      trigger(:call, client, call_id, proc_uri, args)
    end

    # Handle a subscribe message from a client
    # SUBSCRIBE data structure [TOPIC]
    def handle_subscribe(client, data)
      topic = @engine.subscribe_client_to_topic client, data[0]

      trigger(:subscribe, client, topic.uri)
    end

    # Handle an unsubscribe message from client
    # UNSUBSCRIBE data structure [TOPIC]
    def handle_unsubscribe(client, data)
      topic = @engine.unsubscribe_client_from_topic(client, data[0])

      trigger(:unsubscribe, client, topic.uri)
    end

    # Handle a message published by a client
    # PUBLISH data structure [TOPIC, DATA, EXCLUDE, INCLUDE]
    def handle_publish(client, data)
      topic_uri, payload, exclude, include = data

      @engine.create_event(client, topic_uri, payload, exclude, include)

      trigger(:publish, client, topic_uri, payload, exclude, include)
    end

    def handle_close(websocket, event)
      # client = @engine.find_clients(websocket: websocket).first
      client = @engine.delete_client(websocket)

      trigger(:disconnect, client)
    end
  end
end
