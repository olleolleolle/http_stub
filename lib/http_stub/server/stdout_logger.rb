module HttpStub
  module Server

    class StdoutLogger

      def self.info(message)
        puts message
      end

    end

  end
end
