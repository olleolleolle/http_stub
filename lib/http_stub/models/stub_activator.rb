module HttpStub
  module Models

    class StubActivator

      def initialize(args)
        @args = args
        @stub = HttpStub::Models::Stub.new(args)
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
