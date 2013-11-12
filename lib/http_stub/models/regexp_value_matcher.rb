module HttpStub
  module Models

    class RegexpValueMatcher

      def self.match?(stub_value, actual_value)
        match_data = stub_value.match(/^regexp:(.*)/)
        match_data && !!Regexp.new(match_data[1]).match(actual_value)
      end

    end

  end
end
