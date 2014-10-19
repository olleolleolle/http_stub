module HttpStub
  module Configurer
    module Request

      class Stub < Net::HTTP::Post

        def initialize(payload)
          super("/stubs")
          @payload = payload
          self.content_type = "application/json"
          self.body = payload.to_json
        end

        def stub_uri
          @payload[:uri]
        end

      end

    end
  end
end
