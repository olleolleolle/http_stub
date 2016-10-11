module HttpStub
  module Configurer
    module DSL

      class ServerEndpointTemplate

        delegate :match_requests, :schema, :respond_with, :trigger, :invoke, to: :@session_endpoint_template
        delegate :build_stub, :add_stub!,                                    to: :@session_endpoint_template

        def initialize(server, default_session, &block)
          @server                    = server
          @session_endpoint_template = default_session.endpoint_template(&block)
        end

        def add_scenario!(name, response_overrides={}, &block)
          @server.add_scenario_with_one_stub!(name, self.build_stub(response_overrides, &block))
        end

      end

    end
  end
end
