module HttpStub
  module Server

    module Stub

      def self.create(args)
        HttpStub::Server::Stub::Stub.new(args)
      end

    end
  end
end
