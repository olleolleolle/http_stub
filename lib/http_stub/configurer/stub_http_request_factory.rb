module HttpStub
  module Configurer

    class StubHttpRequestFactory

      def self.create(uri, options)
        request = Net::HTTP::Post.new("/stubs")
        request.content_type = "application/json"
        request.body = {
            "uri" => uri,
            "method" => options[:method],
            "headers" => options[:headers] || {},
            "parameters" => options[:parameters] || {},
            "response" => {
                "status" => options[:response][:status] || "200",
                "body" => options[:response][:body]
            }
        }.to_json
        request
      end

    end

  end
end
