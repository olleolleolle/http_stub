module HttpStub
  module Server
    module Stub

      module Response

        def self.create(args)
          if args["body"].is_a?(Hash)
            HttpStub::Server::Stub::Response::File.new(args)
          else
            HttpStub::Server::Stub::Response::Text.new(args)
          end
        end

      end

    end
  end
end
