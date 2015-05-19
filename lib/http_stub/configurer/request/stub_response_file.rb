module HttpStub
  module Configurer
    module Request

      class StubResponseFile

        attr_reader :id, :path, :name, :type

        def initialize(args)
          @id   = args[:id]
          @path = args[:path]
          @name = args[:name]
          @type = args[:type]
        end

      end

    end
  end
end
