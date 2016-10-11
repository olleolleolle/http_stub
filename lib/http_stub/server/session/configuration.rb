module HttpStub
  module Server
    module Session

      class Configuration

        DEFAULT_CONFIGURATION = [
          { parameter: HttpStub::Server::Session::ID_ATTRIBUTE_NAME },
          { header:    HttpStub::Server::Session::ID_ATTRIBUTE_NAME }
        ].freeze
        DEFAULT_IDENTIFIER = HttpStub::Server::Session::MEMORY_SESSION_ID

        private_constant :DEFAULT_CONFIGURATION, :DEFAULT_IDENTIFIER

        attr_reader :identifier_configuration

        attr_accessor :default_identifier

        def initialize(identifier_setting)
          @identifier_configuration = DEFAULT_CONFIGURATION + (identifier_setting ? [ identifier_setting ] : [])
          @default_identifier       = DEFAULT_IDENTIFIER
        end

        def reset
          @default_identifier = DEFAULT_IDENTIFIER
        end

      end

    end
  end
end
