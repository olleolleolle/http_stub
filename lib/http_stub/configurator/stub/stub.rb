module HttpStub
  module Configurator
    module Stub

      class Stub

        def initialize(parent=nil, &block)
          @hash = {
            match_rules: {},
            response:    { blocks: [] },
            triggers:    { scenario_names: [], stubs: [] }
          }.with_indifferent_access
          self.merge!(parent) if parent
          self.invoke(&block) if block_given?
        end

        def match_requests(args)
          self.tap { @hash[:match_rules].deep_merge!(args) }
        end

        def schema(type, definition)
          { schema: { type: type, definition: definition } }
        end

        def respond_with(args={}, &block)
          remaining_args = args.clone
          response_args  = @hash[:response]
          response_args[:blocks].concat(remaining_args.delete(:blocks) || [])
          response_args[:blocks] << block if block_given?
          self.tap { response_args.deep_merge!(remaining_args) }
        end

        def trigger(args)
          resolved_args = to_triggers(args)
          triggers_args = @hash[:triggers]
          triggers_args[:scenario_names].concat(resolved_args[:scenario_names])
          triggers_args[:stubs].concat(resolved_args[:stubs])
          self
        end

        def invoke(additional_arg=nil, &block)
          block.arity.zero? ? self.instance_eval(&block) : yield(*[ self, additional_arg ].compact)
        end

        def merge!(stub)
          stub_hash = stub.to_hash
          self.match_requests(stub_hash[:match_rules])
          self.respond_with(stub_hash[:response])
          self.trigger(scenarios: stub_hash[:triggers][:scenario_names], stubs: stub_hash[:triggers][:stubs])
        end

        def id
          basic_response = @hash[:response].clone.tap { |hash| hash[:blocks] = hash[:blocks].map(&:source_location) }
          Digest::MD5.hexdigest([ @hash[:match_rules], basic_response, @hash[:triggers] ].to_s)
        end

        def to_hash
          @hash.merge(id: id)
        end

        private

        def to_triggers(args)
          {}.tap do |resolved_args|
            resolved_args[:scenario_names] = args[:scenario] ? [ args[:scenario] ] : args[:scenarios] || []
            stubs = args[:stub] ? [ args[:stub] ] : args[:stubs] || []
            resolved_args[:stubs] = stubs.map(&:to_hash)
          end
        end

      end

    end
  end
end
