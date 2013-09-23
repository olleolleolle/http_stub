module HttpStub
  module Configurer

    class Command

      attr_reader :request, :description

      def initialize(options)
        @processor = options[:processor]
        @request = options[:request]
        @description = options[:description]
        @resetable_flag = !!options[:resetable]
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
