module HttpStub
  module Server
    module Stub
      module Match

        class Controller

          def last_match(request, logger)
            result = request.session.last_match(request.parameters.slice(:method, :uri), logger)
            result ? HttpStub::Server::Response.ok("body" => result.to_json) : HttpStub::Server::Response::NOT_FOUND
          end

          def matches(request)
            request.session.matches
          end

          def misses(request)
            request.session.misses
          end

        end

      end
    end
  end
end
