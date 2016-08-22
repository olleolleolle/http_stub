module HttpStub
  module Server
    module Stub

      class Triggers

        attr_reader :scenario_names
        attr_reader :stubs

        def initialize(args={})
          resolved_args = { "scenario_names" => [], "stubs" => [] }.merge(args || {})
          @scenario_names = resolved_args["scenario_names"]
          @stubs          = resolved_args["stubs"].map { |stub_args| HttpStub::Server::Stub.create(stub_args) }
          @description    = resolved_args.to_s
        end

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
