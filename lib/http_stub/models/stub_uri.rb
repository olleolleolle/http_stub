module HttpStub
  module Models

    class StubUri

      def initialize(uri)
        @uri = uri
      end

      def match?(request)
        match_data = @uri.match(/^regexp:(.*)/)
        match_data ? !!Regexp.new(match_data[1]).match(request.path_info) : request.path_info == @uri
      end

      def to_s
        @uri
      end

    end

  end
end
