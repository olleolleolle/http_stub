module HttpStub
  module Server
    module Stub

      class Registry

        delegate :add, :concat, :find, :all, :clear, to: :@stub_registry

        def initialize
          @stub_registry = HttpStub::Server::Registry.new("stub")
        end

        alias_method :match, :find

        def remember
          @remembered_stub = @stub_registry.last
        end

        def recall
          @stub_registry.rollback_to(@remembered_stub) if @remembered_stub
        end

      end

    end
  end
end
