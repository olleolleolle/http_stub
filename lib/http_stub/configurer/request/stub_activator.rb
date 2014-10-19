module HttpStub
  module Configurer
    module Request

      class StubActivator < Net::HTTP::Post

        def initialize(payload)
          super("/stubs/activators")
          @payload = payload
          self.content_type = "application/json"
          self.body = payload.to_json
        end

        def activation_uri
          @payload[:activation_uri]
        end

      end

    end
  end
end
