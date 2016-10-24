module HttpStub
  module Server
    module Session

      class Controller

        def initialize(session_configuration, server_memory)
          @session_configuration = session_configuration
          @server_memory         = server_memory
        end

        def find(request, logger)
          @server_memory.sessions.find(request.session_id, logger)
        end

        def find_transactional(logger)
          @server_memory.sessions.find(HttpStub::Server::Session::TRANSACTIONAL_SESSION_ID, logger)
        end

        def find_all
          @server_memory.sessions.all
        end

        def delete(request, logger)
          @server_memory.sessions.delete(request.session_id, logger)
        end

        def clear(logger)
          @server_memory.sessions.clear(logger)
        end

      end

    end
  end
end
