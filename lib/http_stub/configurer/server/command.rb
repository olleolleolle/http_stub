module HttpStub
  module Configurer
    module Server

      class Command

        attr_reader :request, :description

        def initialize(args)
          @request = args[:request]
          @description = args[:description]
        end

      end

    end
  end
end
