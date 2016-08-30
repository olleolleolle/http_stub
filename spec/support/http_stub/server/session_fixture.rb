module HttpStub
  module Server

    class SessionFixture

      class << self

        def create(request=HttpStub::Server::RequestFixture.create)
          session_factory.create(request, HttpServerManager::Test::SilentLogger)
        end

        private

        def session_factory
          @session_factory ||= HttpStub::Server::Session::Factory.new(
            nil, HttpStub::Server::Registry.new("session"), HttpStub::Server::Registry.new("scenario")
          )
        end

      end

    end

  end
end
