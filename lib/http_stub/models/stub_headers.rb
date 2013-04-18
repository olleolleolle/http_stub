module HttpStub
  module Models

    class StubHeaders

      def initialize(headers)
        @headers = HttpStub::Models::HashWithRegexpableValues.new((headers || {}).downcase_and_underscore_keys)
      end

      def match?(request)
        @headers.match?(headers_in(request).downcase_and_underscore_keys)
      end

      def to_s
        @headers ? @headers.map { |key_and_value| key_and_value.map(&:to_s).join(":") }.join(", ") : ""
      end

      private

      def headers_in(request)
        HttpStub::Models::RequestHeaderParser.parse(request)
      end

    end

  end
end
