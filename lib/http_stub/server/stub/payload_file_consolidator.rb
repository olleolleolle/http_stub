module HttpStub
  module Server
    module Stub

      class PayloadFileConsolidator

        def self.consolidate!(payload, request)
          response_file = request.parameters["response_file_#{payload["id"]}"]
          payload["response"]["body"] = response_file if response_file
          payload["triggers"].each { |trigger_payload| consolidate!(trigger_payload, request) } if payload["triggers"]
          payload
        end

      end

    end
  end
end
