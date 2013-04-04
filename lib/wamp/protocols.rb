module WAMP
  module Protocols
    ROOT = File.expand_path(File.dirname(__FILE__))

    autoload :Version1,    File.join(ROOT, "protocols", "version_1")
  end
end
