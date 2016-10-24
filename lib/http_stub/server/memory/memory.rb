module HttpStub
  module Server
    module Memory

      class Memory

        DEFAULT_STATUS     = "Started".freeze
        INITIALIZED_STATUS = "Initialized".freeze

        SESSION_ID = HttpStub::Server::Session::MEMORY_SESSION_ID

        private_constant :DEFAULT_STATUS, :INITIALIZED_STATUS, :SESSION_ID

        attr_reader :status, :scenarios, :sessions

        def initialize(session_configuration)
          @status    = DEFAULT_STATUS
          @scenarios = HttpStub::Server::Registry.new("scenario")
          @session   = HttpStub::Server::Session::Session.new(SESSION_ID, @scenarios, HttpStub::Server::Session::Empty)
          @sessions  = HttpStub::Server::Session::Registry.new(session_configuration, @scenarios, @session)
        end

        def initialized!
          @status = INITIALIZED_STATUS
        end

        def stubs
          @session.stubs
        end

        def reset(logger)
          @scenarios.clear(logger)
          @sessions.clear(logger)
          @status = DEFAULT_STATUS
        end

      end

    end
  end
end
