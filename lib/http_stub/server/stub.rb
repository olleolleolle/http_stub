module HttpStub
  module Server

    module Stub

      def self.create(hash)
        HttpStub::Server::Stub::Stub.new(hash)
      end

    end

  end
end
