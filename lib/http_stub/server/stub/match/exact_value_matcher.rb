module HttpStub
  module Server
    module Stub
      module Match

        class ExactValueMatcher

          def self.match?(stub_value, actual_value)
            stub_match_value = stub_value && !stub_value.is_a?(Symbol) ? stub_value.to_s : stub_value
            stub_match_value == actual_value
          end

        end

      end
    end
  end
end
