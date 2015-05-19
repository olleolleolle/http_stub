module HttpStub
  module Server

    class StubController

      def initialize(registry)
        @registry = registry
      end

      def register(request)
        @registry.add(HttpStub::Server::StubFactory.create(request), request)
        HttpStub::Server::Response::SUCCESS
      end

      def replay(request)
        stub = @registry.find_for(request)
        stub ? stub.response : HttpStub::Server::Response::EMPTY
      end

      def clear(request)
        @registry.clear(request)
      end

    end

  end
end
