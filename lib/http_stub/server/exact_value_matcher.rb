module HttpStub
  module Server

    class ExactValueMatcher

      def self.match?(stub_value, actual_value)
        stub_value == actual_value
      end

    end

  end
end
