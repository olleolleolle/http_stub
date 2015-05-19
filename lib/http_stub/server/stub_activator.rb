module HttpStub
  module Server

    class StubActivator

      def self.create_from(request)
        self.new(JSON.parse(request.params["payload"] || request.body.read))
      end

      def initialize(args)
        @args = args
        @stub = HttpStub::Server::Stub.new(args)
      end

      def satisfies?(request)
        activation_uri == request.path_info
      end

      def the_stub
        @stub
      end

      def activation_uri
        @args["activation_uri"]
      end

      def to_s
        @args.to_s
      end

    end

  end
end
