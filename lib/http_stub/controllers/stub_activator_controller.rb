module HttpStub
  module Controllers

    class StubActivatorController

      def initialize(stub_activator_registry, stub_registry)
        @stub_activator_registry = stub_activator_registry
        @stub_registry = stub_registry
      end

      def register(request)
        @stub_activator_registry.add(HttpStub::Models::StubActivator.new(JSON.parse(request.body.read)), request)
        HttpStub::Response::SUCCESS
      end

      def activate(request)
        activator = @stub_activator_registry.find_for(request)
        if activator
          @stub_registry.add(activator.the_stub, request)
          HttpStub::Response::SUCCESS
        else
          HttpStub::Response::EMPTY
        end
      end

      def clear(request)
        @stub_activator_registry.clear(request)
      end

    end

  end
end
