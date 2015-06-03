module HttpStub
  module Server
    module Scenario

      class Instance

        attr_reader :stubs

        def initialize(args)
          @args  = args
          @stubs = args["stubs"].map { |stub_args| HttpStub::Server::Stub.create(stub_args) }
        end

        def satisfies?(request)
          activation_uri == request.path_info
        end

        def activation_uri
          @args["activation_uri"].start_with?("/") ? @args["activation_uri"] : "/#{@args["activation_uri"]}"
        end

        def to_s
          @args.to_s
        end

      end

    end
  end
end
