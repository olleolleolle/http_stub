module HttpStub
  module Server

    class StubFixture

      class << self

        def create(args={})
          HttpStub::Server::Stub.create(HttpStub::Configurator::StubFixture.create_hash(args))
        end

        def many
          (1..3).map { self.create }
        end

      end

    end

  end
end
