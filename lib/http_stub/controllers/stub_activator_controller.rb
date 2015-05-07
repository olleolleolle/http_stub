module HttpStub
  module Controllers

    class StubActivatorController

      def initialize(stub_activator_registry, stub_registry)
        @stub_activator_registry = stub_activator_registry
        @stub_registry = stub_registry
      end

      def register(request)
        @stub_activator_registry.add(HttpStub::Models::StubActivator.create_from(request), request)
        HttpStub::Models::Response::SUCCESS
      end

      def activate(request)
        activator = @stub_activator_registry.find_for(request)
        if activator
          @stub_registry.add(activator.the_stub, request)
          HttpStub::Models::Response::SUCCESS
        else
          HttpStub::Models::Response::EMPTY
        end
      end

      def clear(request)
        @stub_activator_registry.clear(request)
      end

    end

  end
end
