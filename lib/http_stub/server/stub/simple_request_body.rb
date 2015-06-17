module HttpStub
  module Server
    module Stub

      class SimpleRequestBody

        def initialize(body)
          @body = HttpStub::Server::Stub::StringValueMatcher.new(body)
        end

        def match?(request)
          @body.match?(request.body.read)
        end

        def to_s
          @body.to_s
        end

      end

    end
  end
end
