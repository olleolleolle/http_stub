module HttpStub
  module Configurer

    class PatientCommandChain

      def initialize(commands=[])
        @commands = commands
      end

      def <<(command)
        @commands << command
      end

      def execute
        @commands.each(&:execute)
      end

      def filter(&block)
        HttpStub::Configurer::PatientCommandChain.new(@commands.select(&block))
      end

    end

  end
end
