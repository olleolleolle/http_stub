module HttpStub
  module Models

    class StubActivator

      def initialize(options)
        @options = options
        @stub = HttpStub::Models::Stub.new(options)
      end

      def satisfies?(request)
        activation_uri == request.path_info
      end

      def the_stub
        @stub
      end

      def activation_uri
        @options["activation_uri"]
      end

    end

  end
end
