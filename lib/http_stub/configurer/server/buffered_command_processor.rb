module HttpStub
  module Configurer
    module Server

      class BufferedCommandProcessor

        def initialize(command_processor)
          @command_processor = command_processor
          @commands = []
        end

        def process(command)
          @commands << command
        end

        def flush
          @commands.each { |command| @command_processor.process(command) }
        end

      end

    end
  end
end
