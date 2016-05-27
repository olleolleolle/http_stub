module HttpStub
  module Server
    module Stub
      module Match
        module Rule

          class Parameters < ::HashWithIndifferentAccess
            include HttpStub::Extensions::Core::Hash::Formatted

            def initialize(parameters)
              super(parameters || {}, "=", "&")
            end

            def matches?(request, _logger)
              HttpStub::Server::Stub::Match::HashMatcher.match?(self, request.parameters)
            end

          end

        end
      end
    end
  end
end
