module HttpStub
  module Server
    module Scenario

      class Controller

        def initialize(scenario_registry, stub_registry)
          @scenario_registry  = scenario_registry
          @scenario_activator = HttpStub::Server::Scenario::Activator.new(scenario_registry, stub_registry)
        end

        def register(request, logger)
          scenario = HttpStub::Server::Scenario.create(HttpStub::Server::Scenario::Parser.parse(request))
          @scenario_registry.add(scenario, logger)
          HttpStub::Server::Response::SUCCESS
        end

        def activate(name, logger)
          scenario = @scenario_registry.find(name, logger)
          if scenario
            @scenario_activator.activate(scenario, logger)
            HttpStub::Server::Response::SUCCESS
          else
            HttpStub::Server::Response::NOT_FOUND
          end
        end

        def clear(logger)
          @scenario_registry.clear(logger)
        end

      end

    end
  end
end
