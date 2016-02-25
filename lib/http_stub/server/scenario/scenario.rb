module HttpStub
  module Server
    module Scenario

      class Scenario

        attr_reader :name, :stubs, :triggered_scenarios

        def initialize(args)
          @args                = args
          @name                = args["name"]
          @stubs               = create_stubs(args["stubs"])
          @triggered_scenarios = create_triggers(args["triggered_scenario_names"])
        end

        def matches?(name, _logger)
          @name == name
        end

        def uri
          HttpStub::Server::Scenario::Uri.create(@name)
        end

        def to_s
          @args.to_s
        end

        private

        def create_stubs(stubs_args)
          stubs_args.map { |stub_args| HttpStub::Server::Stub.create(stub_args) }
        end

        def create_triggers(scenario_names)
          scenario_names.map { |scenario_name| HttpStub::Server::Scenario::Trigger.new(scenario_name) }
        end

      end

    end
  end
end
