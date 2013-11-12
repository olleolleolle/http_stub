module HttpStub
  module Models

    class ValueMatcher

      private

      MATCHERS = [ HttpStub::Models::OmittedValueMatcher,
                   HttpStub::Models::RegexpValueMatcher,
                   HttpStub::Models::ExactValueMatcher ].freeze

      public

      def initialize(stub_value)
        @stub_value = stub_value
      end

      def match?(actual_value)
        !!MATCHERS.find { |matcher| matcher.match?(@stub_value, actual_value) }
      end

      def to_s
        @stub_value
      end

    end

  end
end
