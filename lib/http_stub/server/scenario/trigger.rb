module HttpStub
  module Server
    module Scenario

      class Trigger

        attr_reader :name, :uri

        def initialize(name)
          @name = name
          @uri  = HttpStub::Server::Scenario::Uri.create
        end

      end

    end
  end
end
