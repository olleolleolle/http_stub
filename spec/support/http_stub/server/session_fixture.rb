module HttpStub
  module Server

    class SessionFixture

      class << self

        def create(id=SecureRandom.uuid)
          HttpStub::Server::Session::Session.new(id, scenario_registry, HttpStub::Server::Session::Empty)
        end

        def memory
          self.create(HttpStub::Server::Session::MEMORY_SESSION_ID)
        end

        private

        def scenario_registry
          @scenario_registry ||= HttpStub::Server::Registry.new("scenario")
        end

      end

    end

  end
end
