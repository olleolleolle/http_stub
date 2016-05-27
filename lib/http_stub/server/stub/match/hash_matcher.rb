module HttpStub
  module Server
    module Stub
      module Match

        class HashMatcher

          def self.match?(stub_hash, actual_hash)
            !stub_hash.find do |(key, value)|
              !HttpStub::Server::Stub::Match::StringValueMatcher.match?(value, actual_hash[key])
            end
          end

        end

      end
    end
  end
end
