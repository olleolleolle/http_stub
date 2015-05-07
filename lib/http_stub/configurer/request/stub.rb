module HttpStub
  module Configurer
    module Request

      class Stub

        def initialize(payload)
          @payload = payload
        end

        def to_http_request
          Net::HTTP::Post::Multipart.new("/stubs", payload: @payload.to_json)
        end

        def stub_uri
          @payload[:uri]
        end

      end

    end
  end
end
