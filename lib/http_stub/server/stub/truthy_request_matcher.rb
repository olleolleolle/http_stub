module HttpStub
  module Server
    module Stub

      class TruthyRequestMatcher

        class << self

          def match?(_request)
            true
          end

          def to_s
            ""
          end

        end

      end

    end
  end
end
