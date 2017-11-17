module HttpStub
  module Server
    module Stub

      class ResponseFixture

        def self.create
          HttpStub::Server::Stub::ResponseBuilder.new.build
        end

      end

    end
  end
end
