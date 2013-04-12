module WAMP
  MAJOR = 0
  MINOR = 0
  PATCH = 1

  ROOT = File.expand_path(File.dirname(__FILE__))

  autoload :Bindable,    File.join(ROOT, "wamp", "bindable")
  autoload :Client,      File.join(ROOT, "wamp", "client")
  autoload :Server,      File.join(ROOT, "wamp", "server")
  autoload :Socket,      File.join(ROOT, "wamp", "socket")
  autoload :Topic,       File.join(ROOT, "wamp", "topic")
  autoload :MessageType, File.join(ROOT, "wamp", "message_type")

  module Engines
    autoload :Memory, File.join(ROOT, "wamp", "engines", "memory")
    autoload :Redis,  File.join(ROOT, "wamp", "engines", "redis")
  end

  module Protocols
    autoload :Version1, File.join(ROOT, "wamp", "protocols", "version_1")
  end

  class << self
    def version
      "#{MAJOR}.#{MINOR}.#{PATCH}"
    end

    def identity
      "WAMP Ruby/#{self.version}"
    end

    def protocol_version
      1
    end
  end
end
