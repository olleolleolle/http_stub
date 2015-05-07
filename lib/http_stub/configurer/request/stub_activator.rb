module HttpStub
  module Configurer
    module Request

      class StubActivator

        def initialize(payload)
          @payload = payload
        end

        def to_http_request
          Net::HTTP::Post::Multipart.new("/stubs/activators", payload: @payload.to_json)
        end

        def activation_uri
          @payload[:activation_uri]
        end

      end

    end
  end
end
