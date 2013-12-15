module HttpStub
  module Configurer

    class Command

      attr_reader :request, :description

      def initialize(args)
        @processor = args[:processor]
        @request = args[:request]
        @description = args[:description]
        @resetable_flag = !!args[:resetable]
      end

      def execute
        @processor.process(self)
      end

      def resetable?
        @resetable_flag
      end

    end

  end
end
