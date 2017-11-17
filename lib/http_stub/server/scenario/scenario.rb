module HttpStub
  module Server
    module Scenario

      class Scenario

        attr_reader :name, :links, :stubs, :triggered_scenarios

        def initialize(hash)
          @args                     = hash
          @name                     = hash[:name]
          @links                    = HttpStub::Server::Scenario::Links.new(@name)
          @initially_activated_flag = hash[:activated]
          @stubs                    = create_stubs(hash[:stubs])
          @triggered_scenarios      = create_triggers(hash[:triggered_scenario_names])
        end

        def initially_activated?
          !!@initially_activated_flag
        end

        def matches?(name, _logger)
          @name == name
        end

        def to_s
          @args.to_s
        end

        private

        def create_stubs(stub_hashes)
          stub_hashes.map { |hash| HttpStub::Server::Stub.create(hash) }
        end

        def create_triggers(scenario_names)
          scenario_names.map { |scenario_name| HttpStub::Server::Scenario::Trigger.new(scenario_name) }
        end

      end

    end
  end
end
