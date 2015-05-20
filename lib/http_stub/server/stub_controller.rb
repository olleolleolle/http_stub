module HttpStub
  module Server

    class StubController

      def initialize(registry)
        @registry = registry
        @request_translator = HttpStub::Server::RequestTranslator.new(HttpStub::Server::Stub)
      end

      def register(request)
        @registry.add(@request_translator.translate(request), request)
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
