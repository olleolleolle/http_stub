module HttpStub
  module Server
    module Stub

      class Registry

        delegate :add, :concat, :all, to: :@stub_registry

        def initialize(match_registry)
          @match_registry = match_registry
          @stub_registry  = HttpStub::Server::Registry.new("stub")
        end

        def find(criteria, logger)
          stub = @stub_registry.find(criteria, logger)
          if criteria.is_a?(HttpStub::Server::Request)
            @match_registry.add(HttpStub::Server::Stub::Match::Match.new(stub, criteria), logger)
            stub.triggers.add_to(self, logger) if stub
          end
          stub
        end

        def remember
          @remembered_stub = @stub_registry.last
        end

        def recall
          @stub_registry.rollback_to(@remembered_stub) if @remembered_stub
        end

        def clear(logger)
          [ @match_registry, @stub_registry ].each { |registry| registry.clear(logger) }
        end

      end

    end
  end
end
