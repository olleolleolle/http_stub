module HttpStub
  module Server
    module Scenario

      class Controller

        def initialize(server_memory)
          @scenario_registry = server_memory.scenario_registry
        end

        def find(request, logger)
          @scenario_registry.find(URI.decode_www_form_component(request.parameters[:name]), logger)
        end

        def find_all
          @scenario_registry.all.sort_by(&:name)
        end

        def activate(request, logger)
          scenario_names = request.parameters[:name] ? [request.parameters[:name] ] : request.parameters[:names]
          scenario_names.each { |name| request.session.activate_scenario!(name, logger) }
          HttpStub::Server::Response::OK
        rescue HttpStub::Server::Scenario::NotFoundError => error
          HttpStub::Server::Response.invalid_request(error)
        end

      end

    end
  end
end
