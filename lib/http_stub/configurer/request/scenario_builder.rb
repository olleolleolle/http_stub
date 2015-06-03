module HttpStub
  module Configurer
    module Request

      class ScenarioBuilder
        include HttpStub::Configurer::Request::StubBuilderProducer

        def initialize(response_defaults, activation_uri)
          @response_defaults = response_defaults
          @activation_uri = activation_uri
          @stub_builders = []
        end

        def add_stub!(builder=nil, &block)
          resolved_builder = builder || build_stub(&block)
          @stub_builders << resolved_builder
        end

        def build
          HttpStub::Configurer::Request::Scenario.new(
            activation_uri: @activation_uri, stubs: @stub_builders.map(&:build)
          )
        end

      end

    end
  end
end
