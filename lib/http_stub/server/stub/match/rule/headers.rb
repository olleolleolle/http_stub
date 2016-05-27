module HttpStub
  module Server
    module Stub
      module Match
        module Rule

          class Headers < ::Hash
            include HttpStub::Extensions::Core::Hash::IndifferentAndInsensitiveAccess
            include HttpStub::Extensions::Core::Hash::Formatted

            def initialize(headers)
              super((headers || {}).underscore_keys, ":")
            end

            def matches?(request, _logger)
              HttpStub::Server::Stub::Match::HashMatcher.match?(self, request.headers)
            end

          end

        end
      end
    end
  end
end
