module HttpStub
  module Configurer
    module DSL

      class Server
        include HttpStub::Configurer::DSL::StubBuilderProducer
        include HttpStub::Configurer::DSL::ScenarioActivator

        attr_accessor :host, :port

        def initialize(server_facade)
          @server_facade        = server_facade
          @default_stub_builder = HttpStub::Configurer::DSL::StubBuilder.new
        end

        def base_uri
          "http://#{host}:#{port}"
        end

        def external_base_uri
          ENV["STUB_EXTERNAL_BASE_URI"] || base_uri
        end

        def request_defaults=(args)
          @default_stub_builder.match_requests(args)
        end

        def response_defaults=(args)
          @default_stub_builder.respond_with(args)
        end

        def has_started!
          @server_facade.server_has_started
        end

        def add_stub!(builder=nil, &block)
          resolved_builder = builder || self.build_stub(&block)
          @server_facade.stub_response(resolved_builder.build)
        end

        def add_scenario!(name, &block)
          builder = HttpStub::Configurer::DSL::ScenarioBuilder.new(@default_stub_builder, name)
          block.call(builder)
          @server_facade.define_scenario(builder.build)
        end

        def add_scenario_with_one_stub!(name, builder=nil, &block)
          add_scenario!(name) do |scenario|
            scenario.add_stub!(builder) { |stub| stub.invoke(&block) }
          end
        end

        def endpoint_template(&block)
          HttpStub::Configurer::DSL::EndpointTemplate.new(self).tap { |template| template.invoke(&block) }
        end

        def add_activator!(&block)
          builder = HttpStub::Configurer::DSL::StubActivatorBuilder.new(@default_stub_builder)
          block.call(builder)
          @server_facade.define_scenario(builder.build)
        end

        def remember_stubs
          @server_facade.remember_stubs
        end

        def recall_stubs!
          @server_facade.recall_stubs
        end

        def clear_stubs!
          @server_facade.clear_stubs
        end

        def clear_scenarios!
          @server_facade.clear_scenarios
        end

        private

        def activate_all!(scenario_names)
          scenario_names.each { |scenario_name| @server_facade.activate(scenario_name) }
        end

      end

    end
  end
end
