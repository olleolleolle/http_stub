module HttpStub
  module Server
    module Scenario

      class RequestParser

        def self.parse(request)
          JSON.parse(request.params["payload"]).tap do |payload|
            payload["stubs"].each do |stub_payload|
              HttpStub::Server::Stub::PayloadFileConsolidator.consolidate!(stub_payload, request)
            end
          end
        end

      end

    end
  end
end
