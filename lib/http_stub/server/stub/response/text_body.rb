module HttpStub
  module Server
    module Stub
      module Response

        class TextBody

          JSON_HEADERS = { "content-type" => "application/json" }.freeze

          private_constant :JSON_HEADERS

          attr_reader :headers, :text

          def initialize(args={})
            @headers = args[:json] ? JSON_HEADERS : {}
            @text    = args[:json].try(:to_json) || args[:body] || ""
          end

          def serve(application, response)
            application.halt(response.status, response.headers, @text)
          end

          def to_s
            @text
          end

        end

      end
    end
  end
end
