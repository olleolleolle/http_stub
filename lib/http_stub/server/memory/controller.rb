module HttpStub
  module Server
    module Memory

      class Controller

        def initialize(server_memory)
          @server_memory = server_memory
        end

        def find_stubs
          @server_memory.stubs
        end

      end

    end
  end
end
