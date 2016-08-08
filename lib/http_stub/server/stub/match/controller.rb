module HttpStub
  module Server
    module Stub
      module Match

        class Controller

          def initialize(result_registry)
            @result_registry = result_registry
          end

          def find_last(request, logger)
            result = @result_registry.find(request.parameters.slice(:method, :uri), logger)
            result ? HttpStub::Server::Response.ok("body" => result.to_json) : HttpStub::Server::Response::NOT_FOUND
          end

        end

      end
    end
  end
end
