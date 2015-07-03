module HttpStub
  module Server
    module Stub
      module Match
        module Rule

          class SimpleBody

            def initialize(body)
              @body = HttpStub::Server::Stub::Match::StringValueMatcher.new(body)
            end

            def matches?(request, _logger)
              @body.matches?(request.body)
            end

            def to_s
              @body.to_s
            end

          end

        end
      end
    end
  end
end
