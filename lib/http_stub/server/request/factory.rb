module HttpStub
  module Server
    module Request

      class Factory

        def initialize(scenario_registry)
          @session = HttpStub::Server::Session.new(scenario_registry)
        end

        def create(rack_request)
          HttpStub::Server::Request::Request.new(rack_request, @session)
        end

      end

    end
  end
end
