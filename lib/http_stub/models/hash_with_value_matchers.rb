module HttpStub
  module Models

    class HashWithValueMatchers < Hash

      def initialize(stub_hash)
        stub_hash.each_pair { |key, value| self[key] = HttpStub::Models::ValueMatcher.new(value) }
      end

      def match?(actual_hash)
        !(self.find do |key_and_value_matcher|
          other_value = actual_hash[key_and_value_matcher[0]]
          !key_and_value_matcher[1].match?(other_value)
        end)
      end

    end

  end
end
