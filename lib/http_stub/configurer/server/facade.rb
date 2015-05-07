module HttpStub
  module Configurer
    module Server

      class Facade

        def initialize(configurer)
          @request_processor = HttpStub::Configurer::Server::RequestProcessor.new(configurer)
        end

        def stub_response(request)
          @request_processor.submit(request: request, description: "stubbing '#{request.stub_uri}'")
        end

        def stub_activator(request)
          @request_processor.submit(request: request, description: "registering activator '#{request.activation_uri}'")
        end

        def activate(uri)
          @request_processor.submit(
            request: as_plain_request(Net::HTTP::Get.new(uri)),
            description: "activating '#{uri}'"
          )
        end

        def remember_stubs
          @request_processor.submit(
            request: as_plain_request(Net::HTTP::Post.new("/stubs/memory").tap { |request| request.body = "" }),
            description: "committing stubs to memory"
          )
        end

        def recall_stubs
          @request_processor.submit(
            request: as_plain_request(Net::HTTP::Get.new("/stubs/memory")),
            description: "recalling stubs in memory"
          )
        end

        def clear_stubs
          @request_processor.submit(
            request: as_plain_request(Net::HTTP::Delete.new("/stubs")),
            description: "clearing stubs")
        end

        def clear_activators
          @request_processor.submit(
            request: as_plain_request(Net::HTTP::Delete.new("/stubs/activators")),
            description: "clearing activators"
          )
        end

        def server_has_started
          @request_processor.disable_buffering!
        end

        def flush_requests
          @request_processor.flush!
        end

        private

        def as_plain_request(http_request)
          HttpStub::Configurer::Request::PlainHttp.new(http_request)
        end

      end

    end
  end
end
