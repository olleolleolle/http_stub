module HttpStub
  module Server
    module Stub
      module Match
        module Rule

          class Headers

            def initialize(headers)
              original_headers   = headers || {}
              @formatted_headers = HttpStub::Server::FormattedHash.new(original_headers, ":")
              @matchable_headers = HttpStub::Server::Stub::Match::HashWithStringValueMatchers.new(
                original_headers.downcase_and_underscore_keys
              )
            end

            def matches?(request, _logger)
              @matchable_headers.matches?(request.headers.downcase_and_underscore_keys)
            end

            def to_s
              @formatted_headers.to_s
            end

          end

        end
      end
    end
  end
end
