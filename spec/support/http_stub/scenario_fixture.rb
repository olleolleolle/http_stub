module HttpStub

  class ScenarioFixture

    def initialize
      @name                     = "some/scenario/name"
      @stub_fixtures            = []
      @triggered_scenario_names = []
    end

    def with_name!(name)
      self.tap { @name = name }
    end

    def with_stubs!(number)
      self.tap { @stub_fixtures.concat((1..number).map { HttpStub::StubFixture.new }) }
    end

    def with_triggered_scenario_names!(uris)
      self.tap { @triggered_scenario_names.concat(uris) }
    end

    def server_payload
      {
        "name"                     => @name,
        "stubs"                    => @stub_fixtures.map(&:server_payload),
        "triggered_scenario_names" => @triggered_scenario_names
      }
    end

  end

end
