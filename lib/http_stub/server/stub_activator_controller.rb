module HttpStub
  module Server

    class StubActivatorController

      def initialize(stub_activator_registry, stub_registry)
        @stub_activator_registry = stub_activator_registry
        @stub_registry = stub_registry
        @request_translator = HttpStub::Server::RequestTranslator.new(HttpStub::Server::StubActivator)
      end

      def register(request)
        @stub_activator_registry.add(@request_translator.translate(request), request)
        HttpStub::Server::Response::SUCCESS
      end

      def activate(request)
        activator = @stub_activator_registry.find_for(request)
        if activator
          @stub_registry.add(activator.the_stub, request)
          HttpStub::Server::Response::SUCCESS
        else
          HttpStub::Server::Response::EMPTY
        end
      end

      def clear(request)
        @stub_activator_registry.clear(request)
      end

    end

  end
end
