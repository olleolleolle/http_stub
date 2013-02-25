module HttpStub
  module Models

    class Alias

      def initialize(options)
        @alias_options = options
        @stub = HttpStub::Models::Stub.new(options)
      end

      def satisfies?(request)
        alias_uri == request.path_info
      end

      def the_stub
        @stub
      end

      def alias_uri
        @alias_options["alias_uri"]
      end

    end

  end
end
