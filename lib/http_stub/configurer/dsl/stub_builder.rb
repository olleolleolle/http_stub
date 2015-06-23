module HttpStub
  module Configurer
    module DSL

      class StubBuilder

        attr_reader :request, :response, :triggers

        public
        
        def initialize(response_defaults={})
          @response = response_defaults.clone
          @triggers = []
        end

        def match_requests(uri, args={})
          self.tap { @request = { uri: uri }.merge(args) }
        end

        def schema(type, definition)
          { schema: { type: type, definition: definition } }
        end

        def respond_with(args)
          self.tap { @response.deep_merge!(args) }
        end

        def trigger(stub_builder_or_builders)
          resolved_builders =
            stub_builder_or_builders.is_a?(Array) ? stub_builder_or_builders : [ stub_builder_or_builders ]
          @triggers.concat(resolved_builders)
          self
        end

        def invoke(&block)
          block.arity == 0 ? self.instance_eval(&block) : block.call(self)
        end

        def merge!(stub_builder)
          @request = (@request || {}).deep_merge(stub_builder.request || {})
          self.respond_with(stub_builder.response)
          self.trigger(stub_builder.triggers)
        end

        def build
          HttpStub::Configurer::Request::Stub.new(request: @request, response: @response, triggers: @triggers)
        end

      end

    end
  end
end
