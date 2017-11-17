module HttpStub
  module Server
    module Memory

      class InitialState

        def initialize(configurator_state)
          @configurator_state = configurator_state
        end

        def load_scenarios
          @configurator_state.scenario_hashes.map { |hash| HttpStub::Server::Scenario.create(hash) }
        end

        def load_stubs(scenario_registry)
          initial_stubs   = @configurator_state.stub_hashes.map { |hash| HttpStub::Server::Stub.create(hash) }
          activated_stubs = scenario_registry.find_all(&:initially_activated?).map do |activated_scenario|
            scenario_registry.stubs_activated_by(activated_scenario, HttpStub::Server::StdoutLogger)
          end.flatten
          initial_stubs + activated_stubs
        end

      end

    end
  end
end
