module HttpStub
  module Server
    module Stub

      class Registry

        delegate :add, :concat, :find, :all, :clear, to: :@stub_registry

        def initialize
          @stub_registry = HttpStub::Server::Registry.new("stub")
        end

        def match(request, logger)
          @stub_registry.find(request, logger).tap do |matched_stub|
            matched_stub.triggers.add_to(self, logger) if matched_stub
          end
        end

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
