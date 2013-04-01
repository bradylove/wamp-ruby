require 'faye/websocket'
require 'json'

module WAMP
  class Server
    include WAMP::Bindable

    attr_accessor :options, :sockets, :topics, :callbacks

    def initialize(options = {})
      @options = options
      @sockets = {}
      @topics  = {}

      @callbacks = {}
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

    def send_event_to_all
      msg = [8, 'ws://localhost:9292/', "Here I am, Rock you like a hurricane"]
      @sockets.each_pair do |s, c|
        s.send msg.to_json
      end
    end

  private

    def handle_open(websocket, event)
      socket = @sockets[websocket] = WAMP::Socket.new(websocket)

      trigger(:connect, socket)
    end

    def handle_message(websocket, event)
      socket = @sockets[websocket]

      parsed_msg = JSON.parse(event.data)
      msg_type   = parsed_msg[0]

      case WAMP::MessageType[msg_type]
      when :PREFIX
        prefix = parsed_msg[1]
        uri    = parsed_msg[2]

        socket.add_prefix(prefix, uri)

        trigger(:prefix, socket, prefix, uri)
      when :CALL
        # TODO handle RPC Call
      when :SUBSCRIBE
        handle_subscribe(socket, parsed_msg)
      when :UNSUBSCRIBE
        topic_name = parsed_msg[1]
        topic = @topics[topic_name]

        trigger(:unsubscribe, socket, topic.name)
      when :PUBLISH
        handle_publish(socket, parsed_msg)
      end
    end

    # Handle a subscribe message from a client
    # SUBSCRIBE data structure [5, TOPIC]
    def handle_subscribe(socket, data)
      topic_uri = data[1]

      topic = @topics[topic_uri] ||= WAMP::Topic.new(topic_uri)
      socket.add_topic(@topics[topic_uri])

      trigger(:subscribe, socket, topic.name)
    end

    # Handle an unsubscribe message from client
    # UNSUBSCRIBE data structure [6, TOPIC]
    def handle_unsubscribe(socket, data)
      topic_uri = data[1]
      topic     = @topics[topic_uri]

      socket.remove_topic(topic) if topic

      trigger(:unsubscribe, socket, topic.name)
    end

    # Handle a message published by a client
    # PUBLISH data structure [7, TOPIC, DATA, EXCLUDE, INCLUDE]
    def handle_publish(socket, data)
      topic   = topics[data[1]]
      payload = data[2]
      exclude = data[3]
      include = data[4]

      if exclude == true
        exclude = [socket.id]
      elsif exclude == false || exclude.nil?
        exclude = []
      end

      # Send payload to all sockets subscribed to topic
      @sockets.each_pair do |k, v|
        next if exclude.include? k

        if v.topics.include? topic
          k.send [WAMP::MessageType[:EVENT], topic.name, payload].to_json
        end
      end

      # Todo: Filter send with include

      trigger(:publish, socket, topic.name, payload, exclude, include)
    end

    def handle_close(websocket, event)
      socket = @sockets.delete(websocket)

      p [socket.id, :close, event.code, event.reason]

      trigger(:disconnect, socket)
    end
  end
end
