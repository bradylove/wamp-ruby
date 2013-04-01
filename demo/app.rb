require '../lib/wamp'
require 'json'
require 'pry'

App = WAMP::Server.new

def log(text)
  puts "[#{Time.now}] #{text}"
end

App.bind(:connect) do |client|
  log "#{client.id} connected"
end

App.bind(:prefix) do |client, prefix, uri|
  log "#{client.id} negotiated #{prefix} as #{uri}"
  log "#{client.id} prefixes: #{client.prefixes.to_s}"
end

App.bind(:subscribe) do |client, topic|
  log "#{client.id} subscribed to #{topic}"
end

App.bind(:unsubscribe) do |client, topic|
  log "#{client.id} unsubscribed from #{topic}"
end

App.bind(:publish) do |client, topic, data|
  log "#{client.id} published #{data} to #{topic}"
end

App.bind(:disconnect) do |client|
  log "#{client.id} disconnected"
end
