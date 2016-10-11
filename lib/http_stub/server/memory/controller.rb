module HttpStub
  module Server
    module Memory

      class Controller

        def initialize(session_configuration, server_memory)
          @session_configuration = session_configuration
          @server_memory         = server_memory
        end

        def find_stubs
          @server_memory.stubs
        end

        def reset(logger)
          @session_configuration.reset
          @server_memory.reset(logger)
        end

      end

    end
  end
end
