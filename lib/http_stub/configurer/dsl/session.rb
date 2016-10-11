module HttpStub
  module Configurer
    module DSL

      class Session

        MEMORY_SESSION_ID        = "http_stub_memory".freeze
        TRANSACTIONAL_SESSION_ID = "http_stub_transactional".freeze

        delegate :build_stub, to: :@default_stub_template

        def initialize(id, server_facade, default_stub_template)
          @id                    = id
          @session_facade        = server_facade.create_session_facade(id)
          @default_stub_template = default_stub_template
        end

        def mark_as_default!
          @session_facade.mark_as_default
        end

        def endpoint_template(&block)
          HttpStub::Configurer::DSL::SessionEndpointTemplate.new(self, @default_stub_template, &block)
        end

        def activate!(*names)
          @session_facade.activate(names)
        end

        def add_stub!(builder=nil, &block)
          resolved_builder = builder || self.build_stub(&block)
          @session_facade.stub_response(resolved_builder.build)
        end

        def add_stubs!(builders)
          builders.each { |builder| add_stub!(builder) }
        end

        def reset!
          @session_facade.reset_stubs
        end

        def clear!
          @session_facade.clear_stubs
        end

        def delete!
          @session_facade.delete
        end

      end

    end
  end
end
