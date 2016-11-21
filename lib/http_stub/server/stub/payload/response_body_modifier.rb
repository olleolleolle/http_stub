module HttpStub
  module Server
    module Stub
      module Payload

        class ResponseBodyModifier

          def self.modify!(payload, request)
            response_file = request.parameters["response_file_#{payload["id"]}"]
            payload["response"]["body"] = response_file if response_file
            if payload["triggers"] && payload["triggers"]["stubs"]
              payload["triggers"]["stubs"].each { |trigger_payload| modify!(trigger_payload, request) }
            end
          end

        end

      end
    end
  end
end
