module HttpStub
  module Configurer
    module DSL

      class Server

        delegate :host, :host=, :port, :port=, :base_uri, :external_base_uri, to: :@configuration
        delegate :session_identifier, :session_identifier=,                   to: :@configuration
        delegate :enable, :enabled?,                                          to: :@configuration

        delegate :activate!, :build_stub, :add_stub!, :add_stubs!, to: :@default_session

        def initialize
          @configuration         = HttpStub::Configurer::Server::Configuration.new
          @server_facade         = HttpStub::Configurer::Server::Facade.new(@configuration)
          @default_stub_template = HttpStub::Configurer::DSL::StubBuilderTemplate.new
          @session_factory       = HttpStub::Configurer::DSL::SessionFactory.new(@server_facade, @default_stub_template)
          @default_session       = @session_factory.memory
          @enabled_features      = []
        end

        def request_defaults=(args)
          @default_stub_template.match_requests(args)
        end

        def response_defaults=(args)
          @default_stub_template.respond_with(args)
        end

        def initialize!
          @server_facade.initialize_server
          @default_session = @session_factory.transactional
        end

        def has_started!
          @server_facade.server_has_started
          @default_session = @session_factory.transactional
        end

        def reset!
          @server_facade.reset
        end

        def add_scenario!(name, &_block)
          builder = HttpStub::Configurer::DSL::ScenarioBuilder.new(name, @default_stub_template)
          yield builder
          @server_facade.define_scenario(builder.build)
        end

        def add_scenario_with_one_stub!(name, builder=nil, &block)
          add_scenario!(name) do |scenario|
            scenario.add_stub!(builder) { |stub| stub.invoke(&block) }
          end
        end

        def endpoint_template(&block)
          HttpStub::Configurer::DSL::ServerEndpointTemplate.new(self, @default_session, &block)
        end

        def session(id)
          @session_factory.create(id)
        end

        def clear_sessions!
          @server_facade.clear_sessions
        end

        def recall_stubs!
          @default_session.reset!
        end

        def clear_stubs!
          @default_session.clear!
        end

      end

    end
  end
end
