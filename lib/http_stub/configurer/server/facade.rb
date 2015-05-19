module HttpStub
  module Configurer
    module Server

      class Facade

        def initialize(configurer)
          @request_processor = HttpStub::Configurer::Server::RequestProcessor.new(configurer)
        end

        def stub_response(model)
          @request_processor.submit(
            request: HttpStub::Configurer::Request::Http::Factory.stub(model),
            description: "stubbing '#{model}'"
          )
        end

        def stub_activator(model)
          @request_processor.submit(
            request: HttpStub::Configurer::Request::Http::Factory.stub_activator(model),
            description: "registering activator '#{model}'"
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
            request: HttpStub::Configurer::Request::Http::Factory.post("/stubs/memory"),
            description: "committing stubs to memory"
          )
        end

        def recall_stubs
          @request_processor.submit(
            request: HttpStub::Configurer::Request::Http::Factory.get("/stubs/memory"),
            description: "recalling stubs in memory"
          )
        end

        def clear_stubs
          @request_processor.submit(
            request: HttpStub::Configurer::Request::Http::Factory.delete("/stubs"),
            description: "clearing stubs")
        end

        def clear_activators
          @request_processor.submit(
            request: HttpStub::Configurer::Request::Http::Factory.delete("/stubs/activators"),
            description: "clearing activators"
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
