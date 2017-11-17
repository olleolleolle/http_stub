module HttpStub
  module Server
    module Session

      class IdentifierStrategy

        DEFAULT_CONFIGURATION = [
          { parameter: HttpStub::Server::Session::ID_ATTRIBUTE_NAME },
          { header:    HttpStub::Server::Session::ID_ATTRIBUTE_NAME }
        ].freeze

        private_constant :DEFAULT_CONFIGURATION

        def initialize(identifier_setting)
          @identifier_configuration = DEFAULT_CONFIGURATION + (identifier_setting ? [ identifier_setting ] : [])
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
