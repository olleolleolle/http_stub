module HttpStub
  module Server
    module Stub
      module Match

        class HashWithStringValueMatchers < Hash

          def initialize(stub_hash)
            stub_hash.each_pair do |key, value|
              self[key] = HttpStub::Server::Stub::Match::StringValueMatcher.new(value)
            end
          end

          def matches?(actual_hash)
            !(self.find do |key_and_value_matcher|
              key, value_matcher = key_and_value_matcher
              !value_matcher.matches?(actual_hash[key])
            end)
          end

        end

      end
    end
  end
end
