module HttpStub
  module Models

    class Stub

      attr_reader :uri, :headers, :parameters, :response, :triggers

      def initialize(args)
        @args = args
        @uri = HttpStub::Models::StubUri.new(args["uri"])
        @headers = HttpStub::Models::StubHeaders.new(args["headers"])
        @parameters = HttpStub::Models::StubParameters.new(args["parameters"])
        @response = HttpStub::Models::Response.new(args["response"])
        @triggers = HttpStub::Models::StubTriggers.new(args["triggers"])
      end

      def satisfies?(request)
        @uri.match?(request) &&
            method.downcase == request.request_method.downcase &&
            @headers.match?(request) &&
            @parameters.match?(request)
      end

      def method
        @args["method"]
      end

      def to_s
        @args.to_s
      end

    end

  end
end
