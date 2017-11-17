module HttpStub
  module Server

    module Scenario

      def self.create(hash)
        HttpStub::Server::Scenario::Scenario.new(hash)
      end

    end
  end
end
