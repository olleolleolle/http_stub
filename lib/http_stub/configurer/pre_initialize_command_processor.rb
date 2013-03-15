module HttpStub
  module Configurer

    class PreInitializeCommandProcessor

      def initialize
        @cache = []
      end

      def process(command)
        @cache << command
      end

      def replay
        @cache.each { |command| command.execute() }
      end

    end

  end
end
