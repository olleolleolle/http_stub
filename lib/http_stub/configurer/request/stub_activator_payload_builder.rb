module HttpStub
  module Configurer
    module Request

      class StubActivatorPayloadBuilder

        delegate :match_requests, :respond_with, :trigger, to: :@stub_payload_builder
        
        def initialize(response_defaults)
          @stub_payload_builder = HttpStub::Configurer::Request::StubPayloadBuilder.new(response_defaults)
        end

        def on(uri)
          @activation_uri = uri
        end

        def build
          { activation_uri: @activation_uri }.merge(@stub_payload_builder.build)
        end

      end

    end
  end
end
