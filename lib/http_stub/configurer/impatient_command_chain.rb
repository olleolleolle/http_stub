module HttpStub
  module Configurer

    class ImpatientCommandChain

      def <<(command)
        command.execute()
      end

    end

  end
end
