require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
  add_filter "/vendor/"
  minimum_coverage 99.2
  refuse_coverage_drop
end if ENV["coverage"]

require 'httparty'
require 'nokogiri'
require 'rack/test'
require 'wait_until'

require 'http_server_manager/test_support'

require File.expand_path('../../lib/http_stub/rake/task_generators', __FILE__)
require File.expand_path('../../lib/http_stub', __FILE__)
require File.expand_path('../../examples/configurer_with_class_activator', __FILE__)
require File.expand_path('../../examples/configurer_with_class_stub', __FILE__)
require File.expand_path('../../examples/configurer_with_initialize_callback', __FILE__)
require File.expand_path('../../examples/configurer_with_complex_initializer', __FILE__)
require File.expand_path('../../examples/configurer_with_many_class_activators', __FILE__)

HttpStub::Daemon.log_dir = File.expand_path('../../tmp/log', __FILE__)
HttpStub::Daemon.pid_dir = File.expand_path('../../tmp/pids', __FILE__)

HttpServerManager.logger = HttpServerManager::Test::SilentLogger

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |file| require file }
