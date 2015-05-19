module HttpStub
  module Configurer
    module Request

      class StubActivatorBuilder

        delegate :match_requests, :respond_with, :trigger, to: :@stub_builder
        
        def initialize(response_defaults)
          @stub_builder = HttpStub::Configurer::Request::StubBuilder.new(response_defaults)
        end

        def on(uri)
          @activation_uri = uri
        end

        def build
          HttpStub::Configurer::Request::StubActivator.new(activation_uri: @activation_uri, stub: @stub_builder.build)
        end

      end

    end
  end
end
