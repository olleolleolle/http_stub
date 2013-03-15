module HttpStub
  module Configurer

    class PostInitializeCommandProcessor

      def initialize(pre_initialize_processor)
        @pre_initialize_processor = pre_initialize_processor
      end

      def process(command)
        command.execute()
      end

      def replay
        @pre_initialize_processor.replay()
      end

    end

  end
end
