module HttpStub
  module Server
    module Stub

      class RequestParser

        def self.parse(request)
          HttpStub::Server::Stub::PayloadFileConsolidator.consolidate!(
            JSON.parse(request.params["payload"] || request.body.read), request
          )
        end

      end

    end
  end
end
