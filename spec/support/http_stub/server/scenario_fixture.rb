module HttpStub
  module Server

    class ScenarioFixture

      def self.create(name="empty")
        HttpStub::Server::Scenario::Scenario.new("name" => name, "stubs" => [], "triggered_scenario_names" => [])
      end

    end

  end
end
