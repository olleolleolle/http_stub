module HttpStub
  module Configurer
    module Request

      class StubBuilder
        
        def initialize(response_defaults)
          @response = response_defaults ? response_defaults.clone : {}
          @triggers = []
        end

        def match_requests(uri, args={})
          @request = { uri: uri }.merge(args)
        end

        def respond_with(args)
          @response.deep_merge!(args)
        end

        def trigger(stub_builder_or_builders)
          resolved_builders =
            stub_builder_or_builders.is_a?(Array) ? stub_builder_or_builders : [ stub_builder_or_builders ]
          @triggers.concat(resolved_builders)
        end

        def build
          HttpStub::Configurer::Request::Stub.new(request: @request, response: @response, triggers: @triggers)
        end

      end

    end
  end
end
