module HttpStub
  module Models

    class Headers

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
        request.env.reduce({}) do |result, element|
          match = element[0].match(/^HTTP_(.*)/)
          result[match[1]] = element[1] if match
          result
        end
      end

    end

  end
end
