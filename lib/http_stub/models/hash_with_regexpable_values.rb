module HttpStub
  module Models

    class HashWithRegexpableValues < Hash

      def initialize(hash)
        hash.each { |entry| self[entry[0]] = HttpStub::Models::RegexpableValue.new(entry[1]) }
      end

      def match?(other_hash)
        !(self.find do |key_and_regexpable_value|
          other_value = other_hash[key_and_regexpable_value[0]]
          !(other_value && key_and_regexpable_value[1].match?(other_value))
        end)
      end

    end

  end
end
