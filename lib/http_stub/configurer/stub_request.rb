module HttpStub
  module Configurer

    class StubRequest < Net::HTTP::Post

      def initialize(uri, options)
        super("/stubs")
        self.content_type = "application/json"
        self.body = {
            "uri" => uri,
            "method" => options[:method],
            "headers" => options[:headers] || {},
            "parameters" => options[:parameters] || {},
            "response" => {
                "status" => options[:response][:status] || "200",
                "body" => options[:response][:body]
            }
        }.to_json
      end

    end

  end
end
