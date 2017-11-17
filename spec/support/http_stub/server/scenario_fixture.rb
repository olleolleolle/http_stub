module HttpStub
  module Server

    class ScenarioFixture

      class << self

        def with_stubs(args={})
          self.create(args.merge(stubs: HttpStub::Configurator::StubFixture.create_hashes))
        end

        def create(args={})
          HttpStub::Server::Scenario::Scenario.new(HttpStub::Configurator::ScenarioFixture.create_hash(args))
        end

        def many
          (1..3).map { self.create }
        end

      end

    end

  end
end
