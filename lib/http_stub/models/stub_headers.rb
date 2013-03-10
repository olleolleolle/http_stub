module HttpStub
  module Models

    class StubHeaders

      def initialize(headers)
        @headers = headers || {}
      end

      def match?(request)
        headers_in(request).downcase_and_underscore_keys.has_hash?(@headers.downcase_and_underscore_keys)
      end

      def to_s
        @headers ? @headers.map { |key_and_value| key_and_value.join(":") }.join(", ") : ""
      end

      private

      def headers_in(request)
        HttpStub::RequestHeaderParser.parse(request)
      end

    end

  end
end
