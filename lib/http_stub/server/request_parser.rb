module HttpStub
  module Server

    class RequestParser

      class << self

        def parse(request)
          JSON.parse(request.params["payload"] || request.body.read).tap do |payload|
            consolidate_files_into_payload(payload, request)
          end
        end

        private

        def consolidate_files_into_payload(payload, request)
          response_file = request.params["response_file_#{payload["id"]}"]
          payload["response"]["body"] = response_file if response_file
          payload["triggers"].each do |trigger_payload|
            consolidate_files_into_payload(trigger_payload, request)
          end if payload["triggers"]
        end

      end

    end

  end
end
