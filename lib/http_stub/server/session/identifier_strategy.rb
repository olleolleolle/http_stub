module HttpStub
  module Server
    module Session

      class IdentifierStrategy

        def initialize(session_configuration)
          @identifier_configuration = session_configuration.identifier_configuration
        end

        def identifier_for(sinatra_request)
          @identifier_configuration.map do |configuration_entry|
            configuration_entry.map do |attribute_type, attribute_name|
              identifier_attributes = attribute_type == :header ? sinatra_request.headers : sinatra_request.parameters
              identifier_attributes[attribute_name]
            end
          end.flatten.compact.first
        end

      end

    end
  end
end
