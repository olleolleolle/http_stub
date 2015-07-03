module HttpStub
  module Server
    module Stub
      module Match

        class ExactValueMatcher

          def self.match?(stub_value, actual_value)
            stub_value == actual_value
          end

        end

      end
    end
  end
end
