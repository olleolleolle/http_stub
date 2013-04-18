module HttpStub
  module Models

    class Stub

      attr_reader :uri, :headers, :parameters, :response

      def initialize(options)
        @options = options
        @uri = HttpStub::Models::StubUri.new(options["uri"])
        @headers = HttpStub::Models::StubHeaders.new(options["headers"])
        @parameters = HttpStub::Models::StubParameters.new(options["parameters"])
        @response = HttpStub::Models::Response.new(options["response"])
      end

      def satisfies?(request)
        @uri.match?(request) &&
            method.downcase == request.request_method.downcase &&
            @headers.match?(request) &&
            @parameters.match?(request)
      end

      def method
        @options["method"]
      end

      def to_s
        @options.to_s
      end

    end

  end
end
