module HttpStub
  module Server
    module Scenario

      class Controller

        def initialize(scenario_registry)
          @scenario_registry = scenario_registry
        end

        def register(request, logger)
          scenario = HttpStub::Server::Scenario.create(HttpStub::Server::Scenario::Parser.parse(request))
          @scenario_registry.add(scenario, logger)
          HttpStub::Server::Response::OK
        end

        def find(request, logger)
          @scenario_registry.find(URI.decode_www_form_component(request.parameters[:name]), logger)
        end

        def find_all
          @scenario_registry.all.sort_by(&:name)
        end

        def activate(request, logger)
          request.session.activate_scenario!(request.parameters[:name], logger)
          HttpStub::Server::Response::OK
        rescue HttpStub::Server::Scenario::NotFoundError
          HttpStub::Server::Response::NOT_FOUND
        end

        def clear(logger)
          @scenario_registry.clear(logger)
        end

      end

    end
  end
end
