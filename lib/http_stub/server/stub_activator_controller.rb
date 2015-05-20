module HttpStub
  module Server

    class StubActivatorController

      def initialize(stub_activator_registry, stub_registry)
        @stub_activator_registry = stub_activator_registry
        @stub_registry = stub_registry
      end

      def register(request)
        stub_activator = HttpStub::Server::StubActivator.new(HttpStub::Server::RequestParser.parse(request))
        @stub_activator_registry.add(stub_activator, request)
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
