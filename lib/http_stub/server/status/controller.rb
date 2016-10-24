module HttpStub
  module Server
    module Status

      class Controller

        def initialize(session_configuration, server_memory)
          @session_configuration = session_configuration
          @server_memory         = server_memory
        end

        def current
          @server_memory.status
        end

        def initialized
          @server_memory.initialized!
          @session_configuration.default_identifier = HttpStub::Server::Session::TRANSACTIONAL_SESSION_ID
        end

      end

    end
  end
end
