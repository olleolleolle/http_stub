module HttpStub
  module Server
    module Stub
      module Match
        module Rule

          class Uri

            def initialize(uri)
              @uri = HttpStub::Server::Stub::Match::StringValueMatcher.new(uri)
            end

            def matches?(request, _logger)
              @uri.matches?(request.uri)
            end

            def to_s
              @uri.to_s
            end

          end

        end
      end
    end
  end
end
