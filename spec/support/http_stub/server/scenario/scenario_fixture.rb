module HttpStub
  module Server
    module Scenario

      class ScenarioFixture

        def self.create
          HttpStub::Server::Scenario::Scenario.new("name" => "empty", "stubs" => [], "triggered_scenario_names" => [])
        end

      end

    end
  end
end
