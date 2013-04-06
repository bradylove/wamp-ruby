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
  end
end
