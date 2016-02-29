module HttpStub
  module Server
    module Scenario

      class Trigger

        attr_reader :name, :links

        def initialize(name)
          @name  = name
          @links = HttpStub::Server::Scenario::Links.new(name)
        end

      end

    end
  end
end
