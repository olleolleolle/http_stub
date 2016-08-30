module HttpStub
  module Server
    module Request

      class Factory

        def initialize(session_configuration, session_registry, scenario_registry)
          @session_factory =
            HttpStub::Server::Session::Factory.new(session_configuration, session_registry, scenario_registry)
        end

        def create(rack_request, sinatra_parameters, logger)
          HttpStub::Server::Request::Request.new(rack_request, sinatra_parameters).tap do |request|
            request.session = @session_factory.create(request, logger)
          end
        end

      end

    end
  end
end
