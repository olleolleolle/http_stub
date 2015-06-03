module HttpStub
  module Server
    module Scenario

      class Controller

        def initialize(scenario_registry, stub_registry)
          @scenario_registry = scenario_registry
          @stub_registry = stub_registry
        end

        def register(request)
          scenario = HttpStub::Server::Scenario.create(HttpStub::Server::Scenario::RequestParser.parse(request))
          @scenario_registry.add(scenario, request)
          HttpStub::Server::Response::SUCCESS
        end

        def activate(request)
          scenario = @scenario_registry.find_for(request)
          if scenario
            @stub_registry.concat(scenario.stubs, request)
            HttpStub::Server::Response::SUCCESS
          else
            HttpStub::Server::Response::EMPTY
          end
        end

        def clear(request)
          @scenario_registry.clear(request)
        end

      end

    end
  end
end
