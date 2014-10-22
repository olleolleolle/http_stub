module HttpStub
  module Configurer
    module Request

      class StubActivatorPayloadBuilder

        delegate :match_request, :respond_with, :and_add_stub, :and_add_stubs, to: :@stub_payload_builder
        
        def initialize
          @stub_payload_builder = HttpStub::Configurer::Request::StubPayloadBuilder.new
        end

        def path(uri)
          @activation_uri = uri
        end

        def build
          { activation_uri: @activation_uri }.merge(@stub_payload_builder.build)
        end

      end

    end
  end
end
