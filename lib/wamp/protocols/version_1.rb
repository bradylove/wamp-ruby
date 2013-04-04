require 'json'

module WAMP::Protocols

  # Describes the WAMP protocol messages per http://www.wamp.ws/spec#call_message
  class Version1
    # @return [Integer] The version of the WAMP protocol defined in this class.
    def version
      1
    end

    # Builds the WELCOME message (server to client)
    # 	[ TYPE_ID_WELCOME , sessionId , protocolVersion, serverIdent ]
    # @param client_id [String] The server generated ID that the WELCOME message
    #   is to be sent to.
    # @return [String] The WELCOME message as a JSON string.
    def welcome(id)
      [type[:WELCOME], id, version, server_ident].to_json
    end

    # Builds the PREFIX message (client to server)
    # 	[ TYPE_ID_PREFIX , prefix , URI ]
    # @param prefix [String] The shortened CURIE prefix to be registered.
    # @param uri    [String] The full URI to register the prefix to.
    # @return [String] The PREFIX message as a JSON string.
    def prefix(prefix, uri)
      [type[:PREFIX], prefix, uri].to_json
    end

    # Builds the RPC CALL message (client to server)
    # 	[ TYPE_ID_CALL , callID , procURI , ... ]
    # @param call_id [String] This should be a randomly generated string to
    # 	identify the RPC call, the call ID will be returned to the client in the
    #   RPC CALLRESULT or CALLERROR messages.
    # @param proc_uri [String] The procURI is a string that identifies the remote
    #   procedure to be called and MUST be a valid URI or CURIE.
    # @param *args [Array] Zero or more additional arguments to be sent with the
    #   CALL message.
    # @return [String] The CALL message as a JSON string
    def call(call_id, proc_uri, *args)
      [type[:CALL], call_id, proc_uri, *args].to_json
    end

    # Builds the RPC CALLRESULT message (server to client)
    # 	[ TYPE_ID_CALLRESULT , callID , result ]
    # @param call_id [String] This should match the call ID given by the client
    # 	by the client.
    # @param result [String, Integer, Hash, Array] The results of the RPC procedure
    #   initiated by the CALL. Defaults to nil of non is given.
    # @return [String] The CALLRESULT message as a JSON string.
    def call_result(call_id, result = nil)
      [type[:CALLRESULT], call_id, result].to_json
    end

    # Builds the RPC CALLERROR message (server to client)
    # 	[ TYPE_ID_CALLERROR , callID , errorURI , errorDesc , errorDetails(Optional) ]
    # @param call_id [String] This should match the call ID given by the client
    # 	by the client.
    # @param error_uri [String]  A CURIE or URI identifying the error.
    # @param error_desc [String] A description of the error that occured.
    # @param error_details [String] Optional. Used to communicate application
    #   error details, defined by the error_uri.
    # @return [String] The ERRORRESULT message as a JSON string.
    def call_error(call_id, error_uri, error_desc, error_details = nil)
      msg = [type[:CALLERROR], call_id, error_uri, error_desc, error_details]
      msg.delete_if { |x| x.nil? }
      msg.to_json
    end

    # Builds the PubSub SUBSCRIBE message (client to server)
    # 	[ TYPE_ID_SUBSCRIBE , topicURI ]
    # @param topic_uri [String] The topic URI or CURIE (from PREFIX) to receive
    #   published events to the given topic.
    # @return [String] The SUBSCRIBE message as a JSON string.
    def subscribe(topic_uri)
      [type[:SUBSCRIBE], topic_uri].to_json
    end

    # Builds the PubSub UNSUBSCRIBE message (client to server)
    # 	[ TYPE_ID_UNSUBSCRIBE , topicURI ]
    # @param topic_uri [String] The topic URI or CURIE to unsubscribe from.
    # @return [String] The UNSUBSCRIBE message as a JSON string.
    def unsubscribe(topic_uri)
      [type[:UNSUBSCRIBE], topic_uri].to_json
    end

    # Builds the PubSub PUBLISH message (client to server)
    # 	[ TYPE_ID_PUBLISH , topicURI , event ]
    # 	[ TYPE_ID_PUBLISH , topicURI , event , excludeMe ]
    # 	[ TYPE_ID_PUBLISH , topicURI , event , exclude , eligible ]
    # @param topic_uri [String] The topic URI or CURIE to publish the event to.
    # @param payload [String, Array, Hash] The payload to be delivered to the
    #   server.
    # @param exclude [true, false, Array<String>] Optional. Determines which
    #   clients to exclude from the delivery of the event from the server, you
    #   can give true or false will exclude/include the sending client, or give
    #   an Array of client ID's to exclude.
    # @param elgible [Array<String>] Optional. An array lf client ID's elgible
    #   to receive the published message.
    # @return [String] The PUBLISH message as a JSON string.
    def publish(topic_uri, event, exclude = nil, elgible = nil)
      msg = [type[:PUBLISH], topic_uri, event]
      msg[3] = exclude unless exclude.nil?
      msg[4] = elgible unless elgible.nil?

      msg.to_json
    end

    # Builds the PubSub EVENT message (server to client)
    #   [ TYPE_ID_EVENT , topicURI , event ]
    # @param topic_uri [String] The topic URI or CURIE to publish the event to.
    # @param event [String, Array, Hash] The payload to be delivered to the clients
    # @return [String] The EVENT message as a JSON string.
    def event(topic_uri, event)
      [type[:EVENT], topic_uri, event].to_json
    end

    private

    def server_ident
      WAMP.identity
    end

    def type
      WAMP::MessageType
    end
  end
end
