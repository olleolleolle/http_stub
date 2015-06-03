module HttpStub
  module Configurer
    module Request

      class StubActivatorBuilder

        delegate :build, to: :@scenario_builder
        delegate :match_requests, :respond_with, :trigger, to: :@stub_builder

        def initialize(response_defaults)
          @response_defaults = response_defaults
        end

        def on(activation_uri)
          @scenario_builder = HttpStub::Configurer::Request::ScenarioBuilder.new(@response_defaults, activation_uri)
          @stub_builder     = HttpStub::Configurer::Request::StubBuilder.new(@response_defaults)
          @scenario_builder.add_stub!(@stub_builder)
        end

      end

    end
  end
end
