module HttpStub
  module Server
    module Request

      class Factory

        def initialize(session_configuration, server_memory)
          @server_memory               = server_memory
          @session_identifier_strategy = HttpStub::Server::Session::IdentifierStrategy.new(session_configuration)
        end

        def create(rack_request, sinatra_parameters, logger)
          sinatra_request = HttpStub::Server::Request::SinatraRequest.new(rack_request, sinatra_parameters)
          session_id      = @session_identifier_strategy.identifier_for(sinatra_request)
          session         = @server_memory.sessions.find_or_create(session_id, logger)
          HttpStub::Server::Request::Request.new(sinatra_request, session_id, session)
        end

      end

    end
  end
end
