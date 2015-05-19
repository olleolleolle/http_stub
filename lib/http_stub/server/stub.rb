module HttpStub
  module Server

    class Stub

      attr_reader :method, :uri, :headers, :parameters, :response, :triggers

      def initialize(args)
        @method      = args["method"]
        @uri         = HttpStub::Server::StubUri.new(args["uri"])
        @headers     = HttpStub::Server::StubHeaders.new(args["headers"])
        @parameters  = HttpStub::Server::StubParameters.new(args["parameters"])
        @response    = HttpStub::Server::StubResponse.create(args["response"])
        @triggers    = HttpStub::Server::StubTriggers.new(args["triggers"])
        @description = args.to_s
      end

      def satisfies?(request)
        @uri.match?(request) &&
            @method.downcase == request.request_method.downcase &&
            @headers.match?(request) &&
            @parameters.match?(request)
      end

      def to_s
        @description
      end

    end

  end
end
