module HttpStub
  module Server
    module Session

      class Factory

        def initialize(session_configuration, session_registry, scenario_registry)
          @identifier_strategy = HttpStub::Server::Session::IdentifierStrategy.new(session_configuration)
          @session_registry    = session_registry
          @scenario_registry   = scenario_registry
        end

        def create(request, logger)
          session_id = @identifier_strategy.identifier_for(request)
          @session_registry.find(session_id, logger) || create_session(session_id, logger)
        end

        private

        def create_session(session_id, logger)
          HttpStub::Server::Session::Session.new(session_id, @scenario_registry).tap do |session|
            @session_registry.add(session, logger)
          end
        end

      end

    end

  end

end
