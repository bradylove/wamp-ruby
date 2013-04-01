module WAMP
  module Bindable
    def available_bindings
      raise NotImplementedError
    end

    def bind(name, &callback)
      raise "Invalid binding: #{name}" unless available_bindings.include? name
      callbacks[name] = callback
    end

    def trigger(name, *args)
      callbacks[name].call *args if callbacks[name]
    end
  end
end
