require '../lib/wamp'
require 'json'
require 'pry'

App2 = WAMP::Server.new(engine: { type: :redis })

def log(text)
  puts "[#{Time.now}] #{text}"
end

App2.bind(:connect) do |client|
  log "#{client.id} connected"
end

App2.bind(:prefix) do |client, prefix, uri|
  log "#{client.id} negotiated #{prefix} as #{uri}"
  log "#{client.id} prefixes: #{client.prefixes.to_s}"
end

App2.bind(:subscribe) do |client, topic|
  log "#{client.id} subscribed to #{topic}"
end

App2.bind(:unsubscribe) do |client, topic|
  log "#{client.id} unsubscribed from #{topic}"
end

App2.bind(:publish) do |client, topic, data|
  log "#{client.id} published #{data} to #{topic}"
end

App2.bind(:disconnect) do |client|
  log "#{client.id} disconnected"
end
