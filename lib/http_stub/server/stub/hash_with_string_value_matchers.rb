module HttpStub
  module Server
    module Stub

      class HashWithStringValueMatchers < Hash

        def initialize(stub_hash)
          stub_hash.each_pair { |key, value| self[key] = HttpStub::Server::Stub::StringValueMatcher.new(value) }
        end

        def match?(actual_hash)
          !(self.find do |key_and_value_matcher|
            key, value_matcher = key_and_value_matcher
            !value_matcher.match?(actual_hash[key])
          end)
        end

      end

    end
  end
end
