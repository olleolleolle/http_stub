module HttpStub
  module Server

    class MemoryFixture

      class << self

        def create(session_configuration=HttpStub::Server::Session::Configuration.new(nil))
          HttpStub::Server::Memory::Memory.new(session_configuration)
        end

      end

    end

  end
end
