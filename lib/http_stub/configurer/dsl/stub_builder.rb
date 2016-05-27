module HttpStub
  module Configurer
    module DSL

      class StubBuilder

        attr_reader :request, :response, :triggers

        def initialize(default_builder=nil)
          @request  = {}
          @response = {}
          @triggers = []
          self.merge!(default_builder) if default_builder
        end

        def match_requests(args)
          self.tap { @request.deep_merge!(args) }
        end

        def schema(type, definition)
          { schema: { type: type, definition: definition } }
        end

        def respond_with(args={}, &_block)
          resolved_args = args
          resolved_args = yield HttpStub::Configurer::DSL::RequestReferencer.new if block_given?
          self.tap { @response.deep_merge!(resolved_args) }
        end

        def trigger(stub_builder_or_builders)
          resolved_builders =
            stub_builder_or_builders.is_a?(Array) ? stub_builder_or_builders : [ stub_builder_or_builders ]
          @triggers.concat(resolved_builders)
          self
        end

        def invoke(&block)
          block.arity == 0 ? self.instance_eval(&block) : (yield self)
        end

        def merge!(stub_builder)
          self.match_requests(stub_builder.request)
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
