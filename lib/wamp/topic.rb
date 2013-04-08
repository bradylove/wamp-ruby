module WAMP
  class Topic
    attr_accessor :uri, :clients

    def initialize(uri)
      @uri     = uri
      @clients = []
    end

    def add_client(client)
      clients << client unless clients.include? client
    end

    def remove_client(client)
      clients.delete client
    end

    def publish(client, protocol, payload, excluded, included)
      rec_clients = clients.dup

      if excluded == true
        excluded = [client.id]
      elsif excluded == false || excluded.nil?
        excluded = []
      end

      rec_clients.delete_if { |c| excluded.include? c.id }

      if included
        rec_clients.delete_if { |c| !included.include?(c.id) }
      end

      rec_clients.each do |c|
        c.websocket.send protocol.event(self.uri, payload)
      end
    end
  end
end
