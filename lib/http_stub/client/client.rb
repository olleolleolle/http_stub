module HttpStub
  module Client

    class Client

      TRANSACTIONAL_SESSION_ID = "http_stub_transactional".freeze

      private_constant :TRANSACTIONAL_SESSION_ID

      delegate :activate!, to: :@default_session

      def initialize(server_uri)
        @server          = HttpStub::Client::Server.new(server_uri)
        @default_session = HttpStub::Client::Session.new(TRANSACTIONAL_SESSION_ID, @server)
      end

      def session(id)
        HttpStub::Client::Session.new(id, @server)
      end

      def reset!
        @server.submit!(method: :delete, path: "sessions", intent: "reset server")
      end

    end

  end
end
