module HttpStub
  module Server
    module Session

      class Factory

        def initialize(scenario_registry, session_configuration)
          @scenario_registry   = scenario_registry
          @identifier_strategy = HttpStub::Server::Session::IdentifierStrategy.new(session_configuration)
          @sessions            = {}
        end

        def create(request)
          @sessions[@identifier_strategy.identifier_for(request)] ||=
            HttpStub::Server::Session::Session.new(@scenario_registry)
        end

      end

    end

  end

end
