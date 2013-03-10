module HttpStub
  module Models

    class Stub

      attr_reader :headers, :parameters, :response

      def initialize(options)
        @stub_options = options
        @headers = HttpStub::Models::StubHeaders.new(options["headers"])
        @parameters = HttpStub::Models::StubParameters.new(options["parameters"])
        @response = HttpStub::Models::Response.new(options["response"])
      end

      def satisfies?(request)
        uri == request.path_info &&
            method.downcase == request.request_method.downcase &&
            @headers.match?(request) &&
            @parameters.match?(request)
      end

      def uri
        @stub_options["uri"]
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
