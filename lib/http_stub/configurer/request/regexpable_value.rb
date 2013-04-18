module HttpStub
  module Configurer
    module Request

      class RegexpableValue

        def initialize(value)
          @value = value
        end

        def to_s
          @value.is_a?(Regexp) ? "regexp:#{@value.source.gsub(/\\/, "")}" : @value
        end

      end
    end
  end
end
