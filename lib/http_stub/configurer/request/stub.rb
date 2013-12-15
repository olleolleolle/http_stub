module HttpStub
  module Configurer
    module Request

      class Stub < Net::HTTP::Post

        def initialize(uri, args)
          super("/stubs")
          self.content_type = "application/json"
          self.body = {
              "uri" => HttpStub::Configurer::Request::ControllableValue.format(uri),
              "method" => args[:method],
              "headers" => HttpStub::Configurer::Request::ControllableValue.format(args[:headers] || {}),
              "parameters" => HttpStub::Configurer::Request::ControllableValue.format(args[:parameters] || {}),
              "response" => {
                  "status" => args[:response][:status] || "",
                  "headers" => args[:response][:headers] || {},
                  "body" => args[:response][:body],
                  "delay_in_seconds" => args[:response][:delay_in_seconds] || ""
              }
          }.to_json
        end

      end

    end
  end
end
