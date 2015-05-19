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
        @remembered_stub = @registry.last
      end

      def recall
        @registry.rollback_to(@remembered_stub) if @remembered_stub
      end

    end

  end
end
