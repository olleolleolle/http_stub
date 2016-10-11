module HttpStub
  module Server
    module Memory

      class Memory

        SESSION_ID = HttpStub::Server::Session::MEMORY_SESSION_ID

        private_constant :SESSION_ID

        attr_reader :scenarios, :sessions

        def initialize(session_configuration)
          @scenarios = HttpStub::Server::Registry.new("scenario")
          @session   = HttpStub::Server::Session::Session.new(SESSION_ID, @scenarios, HttpStub::Server::Session::Empty)
          @sessions  = HttpStub::Server::Session::Registry.new(session_configuration, @scenarios, @session)
        end

        def stubs
          @session.stubs
        end

        def reset(logger)
          @scenarios.clear(logger)
          @sessions.clear(logger)
        end

      end

    end
  end
end
