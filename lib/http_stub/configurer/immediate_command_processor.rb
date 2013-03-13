module HttpStub
  module Configurer

    class ImmediateCommandProcessor

      def process(command)
        command.execute()
      end

      def flush
        # Intentionally blank
      end

    end

  end
end
