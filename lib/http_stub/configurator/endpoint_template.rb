module HttpStub
  module Configurator

    class EndpointTemplate

      delegate :match_requests, :schema, :respond_with, :trigger, :invoke, :build_stub, to: :@stub_template

      def initialize(server, default_stub_template, &block)
        @server        = server
        @stub_template = HttpStub::Configurator::Stub::Template.new(default_stub_template, &block)
      end

      def add_scenario!(name, response_overrides={}, &block)
        @server.add_scenario_with_one_stub!(name, self.build_stub(response_overrides), &block)
      end

      def add_stub!(response_overrides={}, &block)
        @server.add_stub!(self.build_stub(response_overrides, &block))
      end

    end

  end
end
