module HttpStub
  module Configurer

    class BufferedCommandProcessor

      def initialize
        @buffer = []
      end

      def process(command)
        @buffer << command
      end

      def flush
        until @buffer.empty?
          command = @buffer.shift
          command.execute()
        end
      end

    end

  end
end
