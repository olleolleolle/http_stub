module HttpStub
  module Server

    class StubUri

      def initialize(uri)
        @uri = HttpStub::Server::StringValueMatcher.new(uri)
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
