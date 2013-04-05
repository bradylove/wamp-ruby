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
			# @return [WAMP::Socket] Returns the newly created socket object
			def create_client(websocket)
				client_id = random_uuid
				@clients[client_id] = WAMP::Socket.new(client_id, websocket)
			end

		private

			def random_uuid
				SecureRandom.uuid
			end
		end
	end
end