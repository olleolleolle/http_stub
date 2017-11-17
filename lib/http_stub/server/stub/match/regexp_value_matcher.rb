module HttpStub
  module Server
    module Stub
      module Match

        class RegexpValueMatcher

          def self.match?(stub_value, actual_value)
            stub_value.is_a?(Regexp) && !!stub_value.match(actual_value)
          end

        end

      end
    end
  end
end
