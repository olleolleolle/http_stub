module HttpStub
  module Server
    module Memory

      class Memory

        attr_reader :scenario_registry, :stubs, :session_registry

        def initialize(configurator_state)
          initial_state = HttpStub::Server::Memory::InitialState.new(configurator_state)
          @scenario_registry = HttpStub::Server::Scenario::Registry.new(initial_state.load_scenarios)
          @stubs             = initial_state.load_stubs(@scenario_registry)
          @session_registry  = HttpStub::Server::Session::Registry.new(@scenario_registry, @stubs)
        end

      end

    end
  end
end
