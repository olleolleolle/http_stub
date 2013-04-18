module HttpStub
  module Configurer
    module Request

      class Stub < Net::HTTP::Post

        def initialize(uri, options)
          super("/stubs")
          self.content_type = "application/json"
          self.body = {
              "uri" => HttpStub::Configurer::Request::RegexpableValue.new(uri),
              "method" => options[:method],
              "headers" => HttpStub::Configurer::Request::HashWithRegexpableValues.new(options[:headers] || {}),
              "parameters" => HttpStub::Configurer::Request::HashWithRegexpableValues.new(options[:parameters] || {}),
              "response" => {
                  "status" => options[:response][:status] || 200,
                  "body" => options[:response][:body]
              }
          }.to_json
        end

      end

    end
  end
end
