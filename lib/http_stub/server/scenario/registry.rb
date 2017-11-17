module HttpStub
  module Server
    module Scenario

      class Registry

        delegate :find, :find_all, :all, to: :@scenario_registry

        def initialize(scenarios)
          @scenario_registry = HttpStub::Server::Registry.new("scenario", scenarios)
        end

        def stubs_activated_by(scenario, logger)
          scenario.stubs + scenario.triggered_scenarios.map(&:name).map do |triggered_scenario_name|
            triggered_scenario = @scenario_registry.find(triggered_scenario_name, logger)
            raise HttpStub::Server::Scenario::NotFoundError, triggered_scenario_name unless triggered_scenario
            stubs_activated_by(triggered_scenario, logger)
          end.flatten
        end

      end

    end
  end
end
