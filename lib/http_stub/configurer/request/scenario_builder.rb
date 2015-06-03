module HttpStub
  module Configurer
    module Request

      class ScenarioBuilder

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

        private

        def build_stub(&block)
          builder = HttpStub::Configurer::Request::StubBuilder.new(@response_defaults)
          block.call(builder) if block_given?
          builder
        end

      end

    end
  end
end
