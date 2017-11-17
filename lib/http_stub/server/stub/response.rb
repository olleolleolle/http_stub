module HttpStub
  module Server
    module Stub

      module Response

        def self.create(args={})
          HttpStub::Server::Stub::Response::Response.new(args)
        end

      end

    end
  end
end
