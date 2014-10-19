module HttpStub
  module Configurer
    module Server

      class ForgottenState

        def <<(command)
          command.execute
        end

      end

    end
  end
end
