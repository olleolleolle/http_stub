module HttpStub
  module Controllers

    class AliasController

      def initialize(alias_registry, stub_registry)
        @alias_registry = alias_registry
        @stub_registry = stub_registry
      end

      def register(request)
        @alias_registry.add(HttpStub::Models::Alias.new(request.body.read), request)
        HttpStub::Response::SUCCESS
      end

      def activate(request)
        the_alias = @alias_registry.find_for(request)
        if the_alias
          @stub_registry.add(the_alias.the_stub, request)
          HttpStub::Response::SUCCESS
        else
          HttpStub::Response::EMPTY
        end
      end

    end

  end
end
