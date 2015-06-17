module HttpStub
  module Server
    module Stub

      class Instance

        attr_reader :method, :uri, :headers, :parameters, :body, :response, :triggers

        def initialize(args)
          @method      = HttpStub::Server::Stub::Method.new(args["method"])
          @uri         = HttpStub::Server::Stub::Uri.new(args["uri"])
          @headers     = HttpStub::Server::Stub::RequestHeaders.new(args["headers"])
          @parameters  = HttpStub::Server::Stub::RequestParameters.new(args["parameters"])
          @body        = HttpStub::Server::Stub::RequestBody.create(args["body"])
          @response    = HttpStub::Server::Stub::Response.create(args["response"])
          @triggers    = HttpStub::Server::Stub::Triggers.new(args["triggers"])
          @description = args.to_s
        end

        def satisfies?(request)
          [ @uri, @method, @headers, @parameters, @body ].all? { |matcher| matcher.match?(request) }
        end

        def to_s
          @description
        end

      end

    end
  end
end
