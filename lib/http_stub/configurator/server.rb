module HttpStub
  module Configurator

    class Server

      delegate :port=, :external_base_uri, to: :@state
      delegate :session_identifier=, to: :@state
      delegate :enable, to: :@state

      delegate :build_stub, to: :@server_stub_template

      def initialize(state)
        @state                = state
        @server_stub_template = HttpStub::Configurator::Stub::Template.new
      end

      def request_defaults=(args)
        @server_stub_template.match_requests(args)
      end

      def response_defaults=(args)
        @server_stub_template.respond_with(args)
      end

      def endpoint_template(&block)
        HttpStub::Configurator::EndpointTemplate.new(self, @server_stub_template, &block)
      end

      def add_scenario!(name, &_block)
        scenario = HttpStub::Configurator::Scenario.new(name, @server_stub_template)
        yield scenario
        @state.add_scenario(scenario)
        scenario
      end

      def add_scenario_with_one_stub!(name, stub=nil, &block)
        add_scenario!(name) do |scenario|
          built_stub = stub || scenario.build_stub
          built_stub.invoke(block.arity == 2 ? scenario : nil, &block) if block_given?
          scenario.add_stub!(built_stub)
        end
      end

      def add_stub!(stub=nil, &block)
        resolved_stub = stub || self.build_stub(&block)
        @state.add_stub(resolved_stub)
      end

      def add_stubs!(stubs)
        stubs.each { |stub| add_stub!(stub) }
      end

    end

  end
end
