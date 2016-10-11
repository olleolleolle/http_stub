module HttpStub
  module Configurer
    module DSL

      class StubBuilder

        attr_reader :request, :response, :triggers

        def initialize(parent_builder=nil, &block)
          @request  = {}
          @response = {}
          @triggers = { scenarios: [], stubs: [] }
          self.merge!(parent_builder) if parent_builder
          self.invoke(&block)         if block_given?
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

        def trigger(args)
          resolved_args = args.clone
          resolved_args[:scenarios] ||= resolved_args[:scenario] ? [ resolved_args[:scenario] ] : []
          resolved_args[:stubs]     ||= resolved_args[:stub] ? [ resolved_args[:stub] ] : []
          @triggers[:scenarios].concat(resolved_args[:scenarios])
          @triggers[:stubs].concat(resolved_args[:stubs])
          self
        end

        def invoke(&block)
          block.arity.zero? ? self.instance_eval(&block) : (yield self)
        end

        def merge!(stub_builder)
          self.match_requests(stub_builder.request)
          self.respond_with(stub_builder.response)
          self.trigger(stub_builder.triggers)
        end

        def build
          HttpStub::Configurer::Request::Stub.new(
            request:  @request,
            response: @response,
            triggers: {
              scenario_names: @triggers[:scenarios],
              stubs:          @triggers[:stubs].map(&:build)
            }
          )
        end

      end

    end
  end
end
