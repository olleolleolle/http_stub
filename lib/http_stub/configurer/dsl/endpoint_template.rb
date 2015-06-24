module HttpStub
  module Configurer
    module DSL

      class EndpointTemplate

        delegate :match_requests, :schema, :respond_with, :trigger, :invoke, to: :@template_stub_builder

        def initialize(server)
          @server = server
          @template_stub_builder = HttpStub::Configurer::DSL::StubBuilder.new
        end

        def build_stub(response_overrides={}, &block)
          @server.build_stub { |stub| compose_stub(stub, response_overrides, &block) }
        end

        def add_stub!(response_overrides={}, &block)
          @server.add_stub! { |stub| compose_stub(stub, response_overrides, &block) }
        end

        def add_scenario!(name, response_overrides={}, &block)
          @server.add_scenario_with_one_stub!(name) { |stub| compose_stub(stub, response_overrides, &block) }
        end

        private

        def compose_stub(stub_builder, response_overrides, &block)
          stub_builder.merge!(@template_stub_builder)
          stub_builder.respond_with(response_overrides)
          stub_builder.invoke(&block) if block_given?
        end

      end

    end
  end
end
