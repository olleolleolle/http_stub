module HttpStub
  module Configurer

    class StubActivatorHttpRequestFactory

      def self.create(activation_uri, stub_uri, options)
        request = Net::HTTP::Post.new("/stubs/activators")
        request.content_type = "application/json"
        stub_request = HttpStub::Configurer::StubHttpRequestFactory.create(stub_uri, options)
        request.body = JSON.parse(stub_request.body).merge({ "activation_uri" => activation_uri }).to_json
        request
      end

    end

  end
end
