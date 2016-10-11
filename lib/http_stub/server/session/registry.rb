module HttpStub
  module Server
    module Session

      class Registry

        delegate :find, :all, :delete, to: :@session_registry

        def initialize(session_configuration, scenario_registry, memory_session)
          @session_configuration = session_configuration
          @scenario_registry     = scenario_registry
          @memory_session        = memory_session
          @session_registry      = HttpStub::Server::Registry.new("session", [ memory_session ])
        end

        def find_or_create(session_id, logger)
          effective_session_id = session_id || @session_configuration.default_identifier
          @session_registry.find(effective_session_id, logger) || create(effective_session_id, logger)
        end

        def clear(logger)
          @memory_session.clear(logger)
          @session_registry.replace([ @memory_session ], logger)
        end

        private

        def create(session_id, logger)
          HttpStub::Server::Session::Session.new(session_id, @scenario_registry, @memory_session).tap do |session|
            @session_registry.add(session, logger)
          end
        end

      end

    end
  end
end
