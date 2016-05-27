module HttpStub
  module Configurer
    module Request

      class Omittable

        class << self

          def format(value)
            value.is_a?(Hash) ? format_hash(value) : value
          end

          private

          def format_hash(hash)
            hash.each_with_object({}) do |(key, value), result|
              result[key] = value == :omitted ? "control:omitted" : value
            end
          end

        end

      end
    end
  end
end
