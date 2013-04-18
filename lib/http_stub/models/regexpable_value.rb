module HttpStub
  module Models

    class RegexpableValue

      def initialize(value)
        @value = value
      end

      def match?(other_value)
        match_data = @value.match(/^regexp:(.*)/)
        match_data ? !!Regexp.new(match_data[1]).match(other_value) : other_value == @value
      end

      def to_s
        @value
      end

    end

  end
end
