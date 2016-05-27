module HttpStub
  module Server
    module Stub
      module Match
        module Rule

          class Uri

            def initialize(uri)
              @uri = uri
            end

            def matches?(request, _logger)
              HttpStub::Server::Stub::Match::StringValueMatcher.match?(@uri, request.uri)
            end

            def to_s
              @uri
            end

          end

        end
      end
    end
  end
end
