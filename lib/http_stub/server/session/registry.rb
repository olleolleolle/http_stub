module HttpStub
  module Server
    module Session

      class Registry

        delegate :find, :all, :delete, :clear, to: :@session_registry

        def initialize(scenario_registry, initial_stubs)
          @scenario_registry = scenario_registry
          @initial_stubs     = initial_stubs
          @session_registry  = HttpStub::Server::Registry.new("session")
        end

        def find_or_create(session_id, logger)
          effective_session_id = session_id || HttpStub::Server::Session::TRANSACTIONAL_SESSION_ID
          @session_registry.find(effective_session_id, logger) || create(effective_session_id, logger)
        end

        private

        def create(session_id, logger)
          HttpStub::Server::Session::Session.new(session_id, @scenario_registry, @initial_stubs).tap do |session|
            @session_registry.add(session, logger)
          end
        end

      end

    end
  end
end
