module HttpStub
  module Configurer
    module Server

      class Facade

        def initialize(configurer)
          @request_processor = HttpStub::Configurer::Server::RequestProcessor.new(configurer)
        end

        def stub_response(model)
          @request_processor.submit(
            request: HttpStub::Configurer::Request::Http::Factory.multipart(model),
            description: "stubbing '#{model}'"
          )
        end

        def define_scenario(model)
          @request_processor.submit(
            request: HttpStub::Configurer::Request::Http::Factory.multipart(model),
            description: "registering scenario '#{model}'"
          )
        end

        def activate(uri)
          @request_processor.submit(
            request: HttpStub::Configurer::Request::Http::Factory.get(uri),
            description: "activating '#{uri}'"
          )
        end

        def remember_stubs
          @request_processor.submit(
            request: HttpStub::Configurer::Request::Http::Factory.post("/http_stub/stubs/memory"),
            description: "committing stubs to memory"
          )
        end

        def recall_stubs
          @request_processor.submit(
            request: HttpStub::Configurer::Request::Http::Factory.get("/http_stub/stubs/memory"),
            description: "recalling stubs in memory"
          )
        end

        def clear_stubs
          @request_processor.submit(
            request: HttpStub::Configurer::Request::Http::Factory.delete("/http_stub/stubs"),
            description: "clearing stubs")
        end

        def clear_scenarios
          @request_processor.submit(
            request: HttpStub::Configurer::Request::Http::Factory.delete("/http_stub/scenarios"),
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
