require 'wamp'

Client = WAMP::Client.new

Client.bind(:connect) do |client|
  puts "Connected to server"
end

Client.bind(:welcome) do |client|
  puts "Welcome message received"
  # client.socket.send [5, "ws://localhost:9000/some_topic"].to_json

  client.subscribe("ws://localhost:9000/some_topic")
  client.publish("ws://localhost:9000/some_topic", { from: client.id, to: "You", what: "Whos there?" })
end

Client.bind(:event) do |client, topic, payload|
  puts "New event on #{topic}: #{payload}"

  if payload["what"] == "Whos there?"
    client.publish("ws://localhost:9000/some_topic", { results: "I am!" }, exclude: true)
  end
end

Client.bind(:disconnect) do |client|
  puts "Disconnected from server"
end

Client.start
