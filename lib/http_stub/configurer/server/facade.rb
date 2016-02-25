module HttpStub
  module Configurer
    module Server

      class Facade

        private

        STUB_MEMORY_URI    = "/http_stub/stubs/memory".freeze
        SCENARIOS_BASE_URI = "/http_stub/scenarios".freeze

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
          @request_processor.submit(
            request:     HttpStub::Configurer::Request::Http::Factory.get(SCENARIOS_BASE_URI, :name => scenario_name),
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
            request:     HttpStub::Configurer::Request::Http::Factory.delete("/http_stub/stubs"),
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
