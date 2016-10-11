module HttpStub
  module Configurer
    module DSL

      class ScenarioBuilder

        delegate :build_stub, to: :@default_stub_template

        def initialize(name, default_stub_template)
          @name                     = name
          @default_stub_template    = default_stub_template
          @triggered_scenario_names = []
          @stub_builders            = []
        end

        def add_stub!(builder=nil, &block)
          resolved_builder = builder || build_stub(&block)
          @stub_builders << resolved_builder
        end

        def add_stubs!(builders)
          builders.each { |builder| add_stub!(builder) }
        end

        def activate!(*names)
          @triggered_scenario_names.concat(names.flatten)
        end

        def build
          HttpStub::Configurer::Request::Scenario.new(
            name: @name, stubs: @stub_builders.map(&:build), triggered_scenario_names: @triggered_scenario_names
          )
        end

      end

    end
  end
end
