module HttpStub
  module Configurator

    class ScenarioBuilder

      def initialize
        @name                     = "Some Scenario Name"
        @stub_builders            = []
        @triggered_scenario_names = []
      end

      def with_name!(name)
        self.tap { @name = name }
      end

      def with_stubs!(number)
        self.tap { @stub_builders.concat((1..number).map { HttpStub::Configurator::StubBuilder.new }) }
      end

      def with_triggered_scenario_names!(names)
        self.tap { @triggered_scenario_names.concat(names) }
      end

      def build_hash
        {
          name:                     @name,
          stubs:                    @stub_builders.map(&:build_hash),
          triggered_scenario_names: @triggered_scenario_names
        }
      end

    end

  end
end
