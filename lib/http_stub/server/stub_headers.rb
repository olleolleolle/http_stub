module HttpStub
  module Server

    class StubHeaders < HttpStub::Server::Headers

      def initialize(headers)
        super(headers)
        @headers = HttpStub::Server::HashWithStringValueMatchers.new((headers || {}).downcase_and_underscore_keys)
      end

      def match?(request)
        @headers.match?(headers_in(request).downcase_and_underscore_keys)
      end

      private

      def headers_in(request)
        HttpStub::Server::RequestHeaderParser.parse(request)
      end

    end

  end
end
