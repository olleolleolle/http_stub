module HttpStub
  module Configurer
    module DSL

      class EndpointTemplate

        delegate :match_requests, :schema, :respond_with, :trigger, :invoke, to: :@default_stub_builder

        def initialize(server, response_defaults)
          @server = server
          @default_stub_builder = HttpStub::Configurer::DSL::StubBuilder.new(response_defaults)
        end

        def add_scenario!(name, response_overrides={}, &block)
          @server.add_one_stub_scenario!(name) do |stub_builder|
            stub_builder.merge!(@default_stub_builder)
            stub_builder.respond_with(response_overrides)
            stub_builder.invoke(&block)
          end
        end

      end

    end
  end
end
