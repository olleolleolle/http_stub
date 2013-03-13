module HttpStub
  module Configurer

    class StubActivatorRequest < Net::HTTP::Post

      def initialize(activation_uri, stub_uri, options)
        super("/stubs/activators")
        stub_request = HttpStub::Configurer::StubRequest.new(stub_uri, options)
        self.content_type = stub_request.content_type
        self.body = JSON.parse(stub_request.body).merge({ "activation_uri" => activation_uri }).to_json
      end

    end

  end
end
