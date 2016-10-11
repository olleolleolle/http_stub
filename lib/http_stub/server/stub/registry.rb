module HttpStub
  module Server
    module Stub

      class Registry

        delegate :add, :concat, :find, :all, :clear, to: :@stub_registry

        alias_method :match, :find

        def initialize(memory_session)
          @memory_session = memory_session
          @stub_registry  = HttpStub::Server::Registry.new("stub", memory_session.stubs)
        end

        def reset(logger)
          @stub_registry.replace(@memory_session.stubs, logger)
        end

      end

    end
  end
end
