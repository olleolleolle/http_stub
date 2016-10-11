module HttpStub
  module Configurer
    module DSL

      class SessionFactory

        MEMORY_SESSION_ID        = "http_stub_memory".freeze
        TRANSACTIONAL_SESSION_ID = "http_stub_transactional".freeze

        private_constant :MEMORY_SESSION_ID, :TRANSACTIONAL_SESSION_ID

        def initialize(server_facade, default_stub_template)
          @server_facade         = server_facade
          @default_stub_template = default_stub_template
          @sessions              = {}
        end

        def create(id)
          @sessions[id] ||= HttpStub::Configurer::DSL::Session.new(id, @server_facade, @default_stub_template)
        end

        def memory
          self.create(MEMORY_SESSION_ID)
        end

        def transactional
          self.create(TRANSACTIONAL_SESSION_ID)
        end

      end

    end
  end
end
