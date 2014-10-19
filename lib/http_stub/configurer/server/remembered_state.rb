module HttpStub
  module Configurer
    module Server

      class RememberedState

        def initialize(commands=[])
          @commands = commands
        end

        def <<(command)
          @commands << command
        end

        def recall
          @commands.each(&:execute)
        end

        def filter(&block)
          HttpStub::Configurer::Server::RememberedState.new(@commands.select(&block))
        end

      end

    end
  end
end
