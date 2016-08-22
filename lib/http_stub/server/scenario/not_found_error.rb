module HttpStub
  module Server
    module Scenario

      class NotFoundError < ::StandardError

        def initialize(name)
          super("Scenario '#{name}' not found")
        end

      end

    end
  end
end
