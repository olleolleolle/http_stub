module HttpStub
  module Server
    module Stub
      module Match
        module Rule

          class SimpleBody

            def initialize(body)
              @body = body
            end

            def matches?(request, _logger)
              HttpStub::Server::Stub::Match::StringValueMatcher.match?(@body, request.body)
            end

            def to_s
              @body
            end

          end

        end
      end
    end
  end
end
