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

Dir[File.expand_path('../../examples/**/*.rb', __FILE__)].each { |file| require file }

HttpStub::Server::Daemon.log_dir = ::File.expand_path('../../tmp/log', __FILE__)
HttpStub::Server::Daemon.pid_dir = ::File.expand_path('../../tmp/pids', __FILE__)

HttpServerManager.logger = HttpServerManager::Test::SilentLogger

module HttpStub

  module Spec
    RESOURCES_DIR = ::File.expand_path('../resources', __FILE__)
  end

end

require_relative 'support/cross_origin_server/integration'
require_relative 'support/cross_origin_server/index_page'
require_relative 'support/http_stub/server/request_fixture'
require_relative 'support/http_stub/server/scenario/scenario_fixture'
require_relative 'support/http_stub/server/stub/match/match_fixture'
require_relative 'support/http_stub/server/stub/match/miss_fixture'
require_relative 'support/http_stub/stub_fixture'
require_relative 'support/http_stub/scenario_fixture'
require_relative 'support/http_stub/empty_configurer'
require_relative 'support/http_stub/server_integration'
require_relative 'support/http_stub/configurer_integration'
require_relative 'support/http_stub/stub_registrator'
require_relative 'support/html_helpers'
require_relative 'support/http_stub/html_view_including_request_details'
require_relative 'support/http_stub/html_view_excluding_request_details'
require_relative 'support/browser_integration'
