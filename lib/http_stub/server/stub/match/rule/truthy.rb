module HttpStub
  module Server
    module Stub
      module Match
        module Rule

          class Truthy

            class << self

              def matches?(_request, _logger)
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
  end
end
