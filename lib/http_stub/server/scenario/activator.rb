module HttpStub
  module Server
    module Scenario

      class Activator

        def initialize(scenario_registry, stub_registry)
          @scenario_registry = scenario_registry
          @stub_registry     = stub_registry
        end

        def activate(scenario, logger)
          @stub_registry.concat(scenario.stubs, logger)
          scenario.triggered_scenarios.each do |triggered_scenario|
            scenario_to_activate = @scenario_registry.find(triggered_scenario.name, logger)
            raise "Scenario not found with name '#{triggered_scenario.name}'" unless scenario_to_activate
            activate(scenario_to_activate, logger)
          end
        end

      end

    end
  end
end
