module HttpStub
  module Models

    class Stub

      attr_reader :uri, :headers, :parameters, :response

      def initialize(options)
        @stub_options = options
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
        @stub_options["method"]
      end

      def to_s
        @stub_options.to_s
      end

    end

  end
end
