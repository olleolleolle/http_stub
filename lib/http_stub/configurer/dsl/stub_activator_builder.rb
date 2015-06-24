module HttpStub
  module Configurer
    module DSL

      class StubActivatorBuilder

        delegate :build, to: :@scenario_builder
        delegate :match_requests, :respond_with, :trigger, to: :@stub_builder

        def initialize(default_stub_builder)
          @default_stub_builder = default_stub_builder
        end

        def on(activation_uri)
          @scenario_builder = HttpStub::Configurer::DSL::ScenarioBuilder.new(@default_stub_builder, activation_uri)
          @stub_builder     = HttpStub::Configurer::DSL::StubBuilder.new(@default_stub_builder)
          @scenario_builder.add_stub!(@stub_builder)
        end

      end

    end
  end
end
