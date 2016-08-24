module HttpStub
  module Server
    module Request

      class Factory

        def initialize(scenario_registry, session_configuration)
          @session_factory = HttpStub::Server::Session::Factory.new(scenario_registry, session_configuration)
        end

        def create(rack_request)
          HttpStub::Server::Request::Request.new(rack_request).tap do |request|
            request.session = @session_factory.create(request)
          end
        end

      end

    end
  end
end
