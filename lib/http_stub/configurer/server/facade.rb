module HttpStub
  module Configurer
    module Server

      class Facade

        private

        STUBS_BASE_URI          = "/http_stub/stubs".freeze
        STUB_MEMORY_URI         = "#{STUBS_BASE_URI}/memory".freeze
        SCENARIOS_BASE_URI      = "/http_stub/scenarios".freeze
        SCENARIO_ACTIVATION_URI = "#{SCENARIOS_BASE_URI}/activate".freeze

        public

        def initialize(configurer)
          @request_processor = HttpStub::Configurer::Server::RequestProcessor.new(configurer)
        end

        def stub_response(model)
          @request_processor.submit(
            request:     HttpStub::Configurer::Request::Http::Factory.multipart(model),
            description: "stubbing '#{model}'"
          )
        end

        def define_scenario(model)
          @request_processor.submit(
            request:     HttpStub::Configurer::Request::Http::Factory.multipart(model),
            description: "registering scenario '#{model}'"
          )
        end

        def activate(scenario_name)
          request = HttpStub::Configurer::Request::Http::Factory.post(SCENARIO_ACTIVATION_URI, :name => scenario_name)
          @request_processor.submit(
            request:     request,
            description: "activating '#{scenario_name}'"
          )
        end

        def remember_stubs
          @request_processor.submit(
            request:      HttpStub::Configurer::Request::Http::Factory.post(STUB_MEMORY_URI),
            description: "committing stubs to memory"
          )
        end

        def recall_stubs
          @request_processor.submit(
            request:     HttpStub::Configurer::Request::Http::Factory.get(STUB_MEMORY_URI),
            description: "recalling stubs in memory"
          )
        end

        def clear_stubs
          @request_processor.submit(
            request:     HttpStub::Configurer::Request::Http::Factory.delete(STUBS_BASE_URI),
            description: "clearing stubs")
        end

        def clear_scenarios
          @request_processor.submit(
            request:     HttpStub::Configurer::Request::Http::Factory.delete(SCENARIOS_BASE_URI),
            description: "clearing scenarios"
          )
        end

        def server_has_started
          @request_processor.disable_buffering!
        end

        def flush_requests
          @request_processor.flush!
        end

      end

    end
  end
end
