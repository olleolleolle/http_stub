module HttpStub
  module Server
    module Stub

      class Uri

        def initialize(uri)
          @uri = HttpStub::Server::Stub::StringValueMatcher.new(uri)
        end

        def match?(request)
          @uri.match?(request.path_info)
        end

        def to_s
          @uri.to_s
        end

      end

    end
  end
end
