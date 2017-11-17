module HttpStub
  module Server
    module Stub
      module Match

        class OmittedValueMatcher

          OMITTED_CONTROL_VALUE = :omitted

          private_constant :OMITTED_CONTROL_VALUE

          def self.match?(stub_value, actual_value)
            stub_value == OMITTED_CONTROL_VALUE && actual_value.nil?
          end

        end

      end
    end
  end
end
