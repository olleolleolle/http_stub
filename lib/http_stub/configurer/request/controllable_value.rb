module HttpStub
  module Configurer
    module Request

      class ControllableValue

        private

        CONTROL_FORMATTERS = [ HttpStub::Configurer::Request::Regexpable,
                               HttpStub::Configurer::Request::Omittable ].freeze

        public

        def self.format(value)
          CONTROL_FORMATTERS.reduce(value) { |result, formatter| formatter.format(result) }
        end

      end
    end
  end
end
