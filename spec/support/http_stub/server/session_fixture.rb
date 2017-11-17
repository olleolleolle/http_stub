module HttpStub
  module Server

    class SessionFixture

      def self.create(id=SecureRandom.uuid)
        HttpStub::Server::Session::Session.new(id, HttpStub::Server::Registry.new("scenario"), [])
      end

    end

  end
end
