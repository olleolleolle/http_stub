module HttpStub
  module Configurer
    module DSL

      class ScenarioBuilder
        include HttpStub::Configurer::DSL::StubBuilderProducer
        include HttpStub::Configurer::DSL::ScenarioActivator

        def initialize(default_stub_builder, name)
          @default_stub_builder     = default_stub_builder
          @name                     = name
          @stub_builders            = []
          @triggered_scenario_names = []
        end

        def add_stub!(builder=nil, &block)
          resolved_builder = builder || build_stub(&block)
          @stub_builders << resolved_builder
        end

        def build
          HttpStub::Configurer::Request::Scenario.new(
            name: @name, stubs: @stub_builders.map(&:build), triggered_scenario_names: @triggered_scenario_names
          )
        end

        private

        def activate_all!(names)
          @triggered_scenario_names.concat(names)
        end

      end

    end
  end
end
