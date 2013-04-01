# encoding: utf-8

require 'rubygems'
require 'bundler'
require './lib/wamp'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "wamp"
  gem.homepage = "http://github.com/bradylove/wamp-ruby"
  gem.license = "MIT"
  gem.summary = %Q{A Ruby implementation of the WAMP WebSocket subprotocol}
  gem.description = %Q{A Ruby implementation of the WAMP (Web Application Messaging Protocol) WebSocket subprotocol}
  gem.email = "love.brady@gmail.com"
  gem.authors = ["Brady Love"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = WAMP.version

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "WAMP #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
