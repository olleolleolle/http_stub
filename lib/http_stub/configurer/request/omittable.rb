module HttpStub
  module Configurer
    module Request

      class Omittable

        class << self

          def format(value)
            value.is_a?(Hash) ? format_hash(value) : value
          end

          private

          def format_hash(value)
            value.reduce({}) do |result, entry|
              key, value  = entry
              result[key] = value == :omitted ? "control:omitted" : value
              result
            end
          end

        end

      end
    end
  end
end
