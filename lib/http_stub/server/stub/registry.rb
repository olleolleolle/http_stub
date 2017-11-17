module HttpStub
  module Server
    module Stub

      class Registry

        delegate :add, :concat, :find, :all, :clear, to: :@stub_registry

        alias_method :match, :find

        def initialize(initial_stubs)
          @initial_stubs = initial_stubs
          @stub_registry = HttpStub::Server::Registry.new("stub", initial_stubs)
        end

        def reset(logger)
          @stub_registry.replace(@initial_stubs, logger)
        end

      end

    end
  end
end
