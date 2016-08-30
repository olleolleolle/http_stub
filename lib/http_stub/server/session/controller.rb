module HttpStub
  module Server
    module Session

      class Controller

        def initialize(session_registry)
          @session_registry = session_registry
        end

        def find(request, logger)
          @session_registry.find(request.parameters[:id], logger)
        end

        def find_all
          @session_registry.all
        end

      end

    end
  end
end
