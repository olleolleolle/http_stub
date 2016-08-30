module HttpStub
  module Server
    module Session

      class IdentifierStrategy

        DEFAULT_CONFIGURATION = { parameter: :http_stub_session_id }.freeze

        private_constant :DEFAULT_CONFIGURATION

        def initialize(configuration)
          @configuration = DEFAULT_CONFIGURATION.to_a + (configuration ? configuration.to_a : [])
        end

        def identifier_for(request)
          @configuration.map do |identifier_attribute_type, identifier_attribute_name|
            identifier_attribute = identifier_attribute_type == :header ? request.headers : request.parameters
            identifier_attribute[identifier_attribute_name]
          end.compact.first || HttpStub::Server::Session::DEFAULT_ID
        end

      end

    end
  end
end
