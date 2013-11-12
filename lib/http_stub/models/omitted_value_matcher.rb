module HttpStub
  module Models

    class OmittedValueMatcher

      private

      OMITTED_CONTROL_VALUE = "control:omitted".freeze

      public

      def self.match?(stub_value, actual_value)
        stub_value == OMITTED_CONTROL_VALUE && actual_value.nil?
      end

    end

  end
end
