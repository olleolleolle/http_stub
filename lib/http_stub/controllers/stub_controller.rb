module HttpStub
  module Controllers

    class StubController

      def initialize(registry)
        @registry = registry
      end

      def register(request)
        @registry.add(HttpStub::Models::Stub.new(JSON.parse(request.body.read)), request)
        HttpStub::Models::Response::SUCCESS
      end

      def replay(request)
        stub = @registry.find_for(request)
        stub ? stub.response : HttpStub::Models::Response::EMPTY
      end

      def clear(request)
        @registry.clear(request)
      end

    end

  end
end
