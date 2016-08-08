module HttpStub
  module Server
    module Stub

      class Parser

        def self.parse(request)
          HttpStub::Server::Stub::Payload.modify!(
            JSON.parse(request.parameters["payload"] || request.body), request
          )
        end

      end

    end
  end
end
