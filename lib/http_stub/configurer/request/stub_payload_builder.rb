module HttpStub
  module Configurer
    module Request

      class StubPayloadBuilder
        
        def initialize
          @args = { triggers: [] }
        end

        def match_request(uri, args={})
          @uri = uri
          @args.merge!(args)
        end

        def respond_with(args)
          @args.merge!(response: args)
        end

        def and_add_stub(stub_builder)
          @args[:triggers] << stub_builder
        end

        def and_add_stubs(stub_builders)
          @args[:triggers].concat(stub_builders)
        end

        def build
          {
            uri: HttpStub::Configurer::Request::ControllableValue.format(@uri),
            method: @args[:method],
            headers: HttpStub::Configurer::Request::ControllableValue.format(@args[:headers] || {}),
            parameters: HttpStub::Configurer::Request::ControllableValue.format(@args[:parameters] || {}),
            response: {
              status: @args[:response][:status] || "",
              headers: @args[:response][:headers] || {},
              body: @args[:response][:body],
              delay_in_seconds: @args[:response][:delay_in_seconds] || ""
            },
            triggers: @args[:triggers].map(&:build)
          }
        end

      end

    end
  end
end
