module HttpStub
  module Configurator

    class Scenario

      delegate :build_stub, to: :@default_stub_template

      def initialize(name, default_stub_template)
        @default_stub_template = default_stub_template
        @hash                  = {
          name:                     name,
          activated:                false,
          stubs:                    [],
          triggered_scenario_names: []
        }.with_indifferent_access
      end

      def add_stub!(stub=nil, &block)
        resolved_stub = stub || build_stub(&block)
        @hash[:stubs] << resolved_stub.to_hash
      end

      def add_stubs!(stubs)
        stubs.each { |stub| add_stub!(stub) }
      end

      def activate_scenarios!(*names)
        @hash[:triggered_scenario_names].concat(names.flatten)
      end

      def activate!
        @hash[:activated] = true
      end

      def to_hash
        @hash
      end

    end

  end
end
