module HttpStub
  module Configurer
    module Server

      class RequestProcessor

        def initialize(configurer)
          @command_processor = HttpStub::Configurer::Server::CommandProcessor.new(configurer)
          @buffered_command_processor = @active_processor =
            HttpStub::Configurer::Server::BufferedCommandProcessor.new(@command_processor)
        end

        def submit(args)
          @active_processor.process(HttpStub::Configurer::Server::Command.new(args))
        end

        def flush!
          @buffered_command_processor.flush
          self.disable_buffering!
        end

        def disable_buffering!
          @active_processor = @command_processor
        end

      end

    end
  end
end
