module HttpStub
  module Server
    module Stub

      class Registry

        delegate :add, :concat, :find, :all, to: :@stub_registry

        def initialize(match_result_registry)
          @match_result_registry = match_result_registry
          @stub_registry         = HttpStub::Server::Registry.new("stub")
        end

        def match(request, logger)
          @stub_registry.find(request, logger).tap do |matched_stub|
            @match_result_registry.add(HttpStub::Server::Stub::Match::Result.new(request, matched_stub), logger)
            matched_stub.triggers.add_to(self, logger) if matched_stub
          end
        end

        def remember
          @remembered_stub = @stub_registry.last
        end

        def recall
          @stub_registry.rollback_to(@remembered_stub) if @remembered_stub
        end

        def clear(logger)
          [ @match_result_registry, @stub_registry ].each { |registry| registry.clear(logger) }
        end

      end

    end
  end
end
