require 'bundler'
Bundler.require(:development)

SimpleCov.start do
  add_filter "/spec/"
  add_filter "/vendor/"
  minimum_coverage 99.2
  refuse_coverage_drop
end if ENV["coverage"]

require 'http_server_manager/test_support'

require_relative '../lib/http_stub/rake/task_generators'
require_relative '../lib/http_stub'
require_relative '../examples/configurer_with_class_activator'
require_relative '../examples/configurer_with_class_stub'
require_relative '../examples/configurer_with_initialize_callback'
require_relative '../examples/configurer_with_complex_initializer'
require_relative '../examples/configurer_with_many_class_activators'

HttpStub::ServerDaemon.log_dir = File.expand_path('../../tmp/log', __FILE__)
HttpStub::ServerDaemon.pid_dir = File.expand_path('../../tmp/pids', __FILE__)

HttpServerManager.logger = HttpServerManager::Test::SilentLogger

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |file| require file }
