module HttpStub
  module Models

    class StubUri

      def initialize(uri)
        @uri = HttpStub::Models::StringValueMatcher.new(uri)
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
