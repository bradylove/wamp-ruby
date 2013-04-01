module WAMP::MessageType
  # Message types with ID per the WAMP Specification located at
  # http://wamp.ws/spec#message_types
  TYPES = {
    WELCOME:     0,
    PREFIX:      1,
    CALL:        2,
    CALLRESULT:  3,
    CALLERROR:   4,
    SUBSCRIBE:   5,
    UNSUBSCRIBE: 6,
    PUBLISH:     7,
    EVENT:       8
  }

  class << self
    # Get MessageType ID with symbolized name, or get symbolized name with an ID
    # Usage:
    #   WAMP::MessageType[:WELCOME] #=> 0
    #   WAMP::MessageType[0]        #=> :WELCOME
    def [](id)
      if id.is_a? Integer
        TYPES.key(id)
      else
        TYPES[id]
      end
    end
  end
end
