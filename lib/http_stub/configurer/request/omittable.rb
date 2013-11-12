module HttpStub
  module Configurer
    module Request

      class Omittable

        def self.format(value)
          value.is_a?(Hash) ? value.reduce({}) do |result, entry|
            key, value = entry
            result[key] = value == :omitted ? "control:omitted" : value
            result
          end : value
        end

      end
    end
  end
end
