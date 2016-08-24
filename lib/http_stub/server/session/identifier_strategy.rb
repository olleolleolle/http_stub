module HttpStub
  module Server
    module Session

      class IdentifierStrategy

        def initialize(configuration)
          resolved_configuration = configuration ? configuration.entries.first : []
          @identifier_attribute_type, @identifier_attribute_name = resolved_configuration
        end

        def identifier_for(request)
          return nil unless @identifier_attribute_type && @identifier_attribute_name
          identifier_attribute = @identifier_attribute_type == :header ? request.headers : request.parameters
          identifier_attribute[@identifier_attribute_name]
        end

      end

    end
  end
end
