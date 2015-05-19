module HttpStub
  module Models

    class Stub

      attr_reader :method, :uri, :headers, :parameters, :response, :triggers

      def initialize(args)
        @method      = args["method"]
        @uri         = HttpStub::Models::StubUri.new(args["uri"])
        @headers     = HttpStub::Models::StubHeaders.new(args["headers"])
        @parameters  = HttpStub::Models::StubParameters.new(args["parameters"])
        @response    = HttpStub::Models::StubResponse.create(args["response"])
        @triggers    = HttpStub::Models::StubTriggers.new(args["triggers"])
        @description = args.to_s
      end

      def satisfies?(request)
        @uri.match?(request) &&
            @method.downcase == request.request_method.downcase &&
            @headers.match?(request) &&
            @parameters.match?(request)
      end

      def clear
        @response.clear
        @triggers.clear
      end

      def to_s
        @description
      end

    end

  end
end
