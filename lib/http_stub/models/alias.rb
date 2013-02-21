module HttpStub
  module Models

    class Alias

      def initialize(request_body)
        @data = JSON.parse(request_body)
        @stub = HttpStub::Models::Stub.new(request_body)
      end

      def satisfies?(request)
        @data["alias_uri"] == request.path_info
      end

      def the_stub
        @stub
      end

    end

  end
end
