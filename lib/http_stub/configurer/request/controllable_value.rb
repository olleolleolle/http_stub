module HttpStub
  module Configurer
    module Request

      class ControllableValue

        CONTROL_FORMATTERS = [ HttpStub::Configurer::Request::Regexpable,
                               HttpStub::Configurer::Request::Omittable ].freeze

        private_constant :CONTROL_FORMATTERS

        def self.format(value)
          CONTROL_FORMATTERS.reduce(value) { |result, formatter| formatter.format(result) }
        end

      end
    end
  end
end
