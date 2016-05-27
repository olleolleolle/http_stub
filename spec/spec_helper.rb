require 'bundler'
Bundler.require(:development)

CodeClimate::TestReporter.start

SimpleCov.start do
  coverage_dir "tmp/coverage"

  add_filter "/spec/"
  add_filter "/vendor/"

  minimum_coverage 100
  refuse_coverage_drop
end if ENV["coverage"]

require 'http_server_manager/test_support'

require_relative '../lib/http_stub/rake/task_generators'
require_relative '../lib/http_stub'
require_relative '../examples/configurer_with_trivial_stub'
require_relative '../examples/configurer_with_deprecated_activator'
require_relative '../examples/configurer_with_trivial_scenarios'
require_relative '../examples/configurer_with_exhaustive_scenarios'
require_relative '../examples/configurer_with_initialize_callback'
require_relative '../examples/configurer_with_complex_initializer'
require_relative '../examples/configurer_with_server_defaults'
require_relative '../examples/configurer_with_stub_triggers'
require_relative '../examples/configurer_with_file_responses'
require_relative '../examples/configurer_with_stub_request_body'
require_relative '../examples/configurer_with_parts'
require_relative '../examples/configurer_with_endpoint_template'
require_relative '../examples/configurer_with_request_references'
require_relative '../examples/authentication_service/configurer'

HttpStub::Server::Daemon.log_dir = ::File.expand_path('../../tmp/log', __FILE__)
HttpStub::Server::Daemon.pid_dir = ::File.expand_path('../../tmp/pids', __FILE__)

HttpServerManager.logger = HttpServerManager::Test::SilentLogger

module HttpStub

  module Spec
    RESOURCES_DIR = ::File.expand_path('../resources', __FILE__)
  end

end

require_relative 'support/http_stub/server/request_fixture'
require_relative 'support/http_stub/server/scenario/scenario_fixture'
require_relative 'support/http_stub/server/stub/match/result_fixture'
require_relative 'support/http_stub/stub_fixture'
require_relative 'support/http_stub/scenario_fixture'
require_relative 'support/http_stub/empty_configurer'
require_relative 'support/html_helpers'
require_relative 'support/server_integration'
require_relative 'support/configurer_integration'
