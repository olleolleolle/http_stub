module HttpStub
  module Server
    module Session

      class Controller

        def initialize(server_memory)
          @server_memory = server_memory
        end

        def find(request, logger)
          @server_memory.session_registry.find(request.session_id, logger)
        end

        def find_transactional(logger)
          @server_memory.session_registry.find(HttpStub::Server::Session::TRANSACTIONAL_SESSION_ID, logger)
        end

        def find_all
          @server_memory.session_registry.all
        end

        def delete(request, logger)
          @server_memory.session_registry.delete(request.session_id, logger)
        end

        def clear(logger)
          @server_memory.session_registry.clear(logger)
        end

      end

    end
  end
end
