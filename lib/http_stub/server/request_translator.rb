module HttpStub
  module Server

    class RequestTranslator

      def initialize(model_class)
        @model_class = model_class
      end

      def translate(request)
        payload = JSON.parse(request.params["payload"] || request.body.read)
        consolidated_payload = consolidate_files_into_payload(payload, request)
        @model_class.new(consolidated_payload)
      end

      private

      def consolidate_files_into_payload(payload, request)
        response_file = request.params["response_file_#{payload["id"]}"]
        payload["response"]["body"] = response_file if response_file
        payload["triggers"].each do |trigger_payload|
          consolidate_files_into_payload(trigger_payload, request)
        end if payload["triggers"]
        payload
      end

    end

  end
end
