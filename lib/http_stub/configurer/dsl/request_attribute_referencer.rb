module HttpStub
  module Configurer
    module DSL

      class RequestAttributeReferencer

        def initialize(attribute_type)
          @attribute_type = attribute_type
        end

        def [](name)
          "control:request.#{@attribute_type}[#{name}]"
        end

      end

    end
  end
end
