module HttpStub
  module Server

    module Stub

      def self.create(args)
        HttpStub::Server::Stub::Instance.new(args)
      end

    end
  end
end
