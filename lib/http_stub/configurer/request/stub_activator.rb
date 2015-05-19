module HttpStub
  module Configurer
    module Request

      class StubActivator

        delegate :response_files, to: :@stub

        def initialize(args)
          @activation_uri = args[:activation_uri]
          @stub           = args[:stub]
        end

        def payload
          { activation_uri: @activation_uri }.merge(@stub.payload)
        end

        def to_s
          @activation_uri
        end

      end

    end
  end
end
