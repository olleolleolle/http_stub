module HttpStub
  module Server
    module Stub

      class RequestHeaders < HttpStub::Server::Stub::Headers

        def initialize(headers)
          super(headers)
          @headers = HttpStub::Server::Stub::HashWithStringValueMatchers.new(
            (headers || {}).downcase_and_underscore_keys
          )
        end

        def match?(request)
          @headers.match?(headers_in(request).downcase_and_underscore_keys)
        end

        private

        def headers_in(request)
          HttpStub::Server::Stub::RequestHeaderParser.parse(request)
        end

      end

    end
  end
end
