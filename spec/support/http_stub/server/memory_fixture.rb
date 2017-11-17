module HttpStub
  module Server

    class MemoryFixture

      class << self

        def create(configurator_state=HttpStub::Configurator::State.new)
          HttpStub::Server::Memory::Memory.new(configurator_state)
        end

      end

    end

  end
end
