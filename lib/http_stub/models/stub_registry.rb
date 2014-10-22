module HttpStub
  module Models

    class StubRegistry

      delegate :add, :all, :clear, to: :@registry

      def initialize
        @registry = HttpStub::Models::Registry.new("stub")
      end

      def find_for(request)
        stub = @registry.find_for(request)
        stub.triggers.add_to(self, request) if stub
        stub
      end

      def remember
        @remembered_registry = @registry.copy
      end

      def recall
        @registry = @remembered_registry.copy if @remembered_registry
      end

    end

  end
end
