module HttpStub
  module Server

    module Scenario

      def self.create(args)
        HttpStub::Server::Scenario::Instance.new(args)
      end

    end
  end
end
