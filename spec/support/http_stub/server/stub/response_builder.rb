module HttpStub
  module Server
    module Stub

      class ResponseBuilder

        def initialize(status=203)
          @status  = status
          @headers = {}
        end

        def with_headers!(headers=HttpStub::HeadersFixture.many)
          self.tap { @headers = headers }
        end

        def build
          HttpStub::Server::Stub::Response.create(status: @status, headers: @headers)
        end

      end

    end
  end
end
