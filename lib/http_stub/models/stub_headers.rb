module HttpStub
  module Models

    class StubHeaders < HttpStub::Models::Headers

      def initialize(headers)
        super(headers)
        @headers = HttpStub::Models::HashWithValueMatchers.new((headers || {}).downcase_and_underscore_keys)
      end

      def match?(request)
        @headers.match?(headers_in(request).downcase_and_underscore_keys)
      end

      private

      def headers_in(request)
        HttpStub::Models::RequestHeaderParser.parse(request)
      end

    end

  end
end
