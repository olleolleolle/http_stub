module HttpStub
  module Configurer
    module Server

      class StateManager

        def initialize(configurer)
          @command_processor = HttpStub::Configurer::Server::CommandProcessor.new(configurer)
          @state = @remembered_state = HttpStub::Configurer::Server::RememberedState.new
        end

        def add(args)
          @state << HttpStub::Configurer::Server::Command.new({ processor: @command_processor }.merge(args))
        end

        def flush_pending_state
          @remembered_state.recall
        end

        def remember
          @state = HttpStub::Configurer::Server::ForgottenState.new
        end

        def recall
          @remembered_state.filter(&:resetable?).recall
        end

      end

    end
  end
end
