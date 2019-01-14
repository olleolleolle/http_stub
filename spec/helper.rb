require 'bundler'
Bundler.require(:development)

SimpleCov.start do
  coverage_dir "tmp/coverage"

  add_filter "/spec/"
  add_filter "/vendor/"

  add_filter "/examples/configurator_with_response_blocks"

  minimum_coverage 100
  refuse_coverage_drop
end if ENV["coverage"]

require 'http_server_manager/test_support'

require_relative '../lib/http_stub/configurator'
require_relative '../lib/http_stub/client'
require_relative '../lib/http_stub/rake/task_generators'

require_relative '../examples/stub_builder'
Dir[::File.expand_path('../examples/**/*.rb', __dir__)].each { |file| require file }

HttpStub::Server::Daemon.log_dir = ::File.expand_path('../tmp/log', __dir__)
HttpStub::Server::Daemon.pid_dir = ::File.expand_path('../tmp/pids', __dir__)

HttpServerManager.logger = HttpServerManager::Test::SilentLogger

module HttpStub

  module Examples
    RESOURCES_DIR = ::File.expand_path('../examples/resources', __dir__)
  end

end

require_relative 'support/include_in_json'
require_relative 'support/contain_file'
require_relative 'support/surpressed_output'
require_relative 'support/object_convertable_to_json'
require_relative 'support/extensions/core/random'
require_relative 'support/rack/request_fixture'
require_relative 'support/rack/rack_application_test'
require_relative 'support/cross_origin_server/integration'
require_relative 'support/cross_origin_server/index_page'
require_relative 'support/http_stub/port'
require_relative 'support/http_stub/headers_fixture'
require_relative 'support/http_stub/configurator/stub_builder'
require_relative 'support/http_stub/configurator/stub_fixture'
require_relative 'support/http_stub/configurator/scenario_builder'
require_relative 'support/http_stub/configurator/scenario_fixture'
require_relative 'support/http_stub/configurator_fixture'
require_relative 'support/http_stub/server/silent_logger'
require_relative 'support/http_stub/server/simple_request'
require_relative 'support/http_stub/server/request/sinatra_request_fixture'
require_relative 'support/http_stub/server/request_fixture'
require_relative 'support/http_stub/server/session_fixture'
require_relative 'support/http_stub/server/scenario_fixture'
require_relative 'support/http_stub/server/memory_fixture'
require_relative 'support/http_stub/server/stub/match/match_fixture'
require_relative 'support/http_stub/server/stub/match/miss_fixture'
require_relative 'support/http_stub/server/stub/response/file_body_fixture'
require_relative 'support/http_stub/server/stub/response/text_body_fixture'
require_relative 'support/http_stub/server/stub/response/blocks_fixture'
require_relative 'support/http_stub/server/stub/response_builder'
require_relative 'support/http_stub/server/stub/response_fixture'
require_relative 'support/http_stub/server/stub_fixture'
require_relative 'support/http_stub/server/application/http_stub_rack_application_test'
require_relative 'support/http_stub/server/driver'
require_relative 'support/http_stub/server_integration'
require_relative 'support/http_stub/configurator_with_stub_builder_and_requester'
require_relative 'support/http_stub/stub_requester'

require_relative 'support/html_helpers'
require_relative 'support/http_stub/html_view_including_a_stub_request'
require_relative 'support/http_stub/html_view_excluding_a_stub_request'
require_relative 'support/http_stub/selenium/browser'
require_relative 'support/browser_integration'

RSpec.configure do |config|
  config.after(:suite) do
    HttpStub::Server::Driver.all.each(&:stop!)
    HttpStub::Selenium::Browser.stop!
  end
end
