module HttpStub
  module Server
    module Stub

      class Triggers

        DEFAULT_ARGS = { scenario_names: [], stubs: [] }.with_indifferent_access.freeze

        private_constant :DEFAULT_ARGS

        attr_reader :scenario_names, :stubs

        def initialize(args={})
          resolved_args   = DEFAULT_ARGS.merge(args || {})
          @scenario_names = resolved_args[:scenario_names]
          @stubs          = create_stubs(resolved_args[:stubs])
          @description    = resolved_args.to_s
        end

        private

        def create_stubs(stub_hashes)
          stub_hashes.map { |hash| HttpStub::Server::Stub.create(hash) }
        end

        public

        EMPTY = HttpStub::Server::Stub::Triggers.new.freeze

        def to_json(*args)
          { scenario_names: @scenario_names, stubs: @stubs }.to_json(*args)
        end

        def to_s
          @description
        end

      end

    end
  end
end
