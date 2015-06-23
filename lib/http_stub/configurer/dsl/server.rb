module HttpStub
  module Configurer
    module DSL

      class Server
        include HttpStub::Configurer::DSL::StubBuilderProducer
        include HttpStub::Configurer::DSL::ScenarioActivator

        attr_accessor :host, :port

        def initialize(server_facade)
          @server_facade     = server_facade
          @response_defaults = {}
        end

        def base_uri
          "http://#{host}:#{port}"
        end

        def response_defaults=(args)
          @response_defaults = args
        end

        def has_started!
          @server_facade.server_has_started
        end

        def add_stub!(builder=nil, &block)
          resolved_builder = builder || self.build_stub(&block)
          @server_facade.stub_response(resolved_builder.build)
        end

        def add_scenario!(name, &block)
          builder = HttpStub::Configurer::DSL::ScenarioBuilder.new(@response_defaults, name)
          block.call(builder)
          @server_facade.define_scenario(builder.build)
        end

        def add_one_stub_scenario!(name, &block)
          add_scenario!(name) do |scenario|
            scenario.add_stub! { |stub| stub.invoke(&block) }
          end
        end

        def endpoint_template(&block)
          HttpStub::Configurer::DSL::EndpointTemplate.new(self, @response_defaults).tap do |template|
            template.invoke(&block)
          end
        end

        def add_activator!(&block)
          builder = HttpStub::Configurer::DSL::StubActivatorBuilder.new(@response_defaults)
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
