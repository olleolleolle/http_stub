module HttpStub
  module Configurer
    module Request

      class StubPayloadBuilder
        
        def initialize(response_defaults)
          @args = { response: response_defaults ? response_defaults.clone : {}, triggers: [] }
        end

        def match_requests(uri, args={})
          @uri = uri
          @args.merge!(args)
        end

        def respond_with(args)
          @args[:response].deep_merge!(args)
        end

        def trigger(stub_builder_or_builders)
          resolved_builders =
            stub_builder_or_builders.is_a?(Array) ? stub_builder_or_builders : [ stub_builder_or_builders ]
          @args[:triggers].concat(resolved_builders)
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
