describe HttpStub::Configurer::Request::PlainHttp do

  let(:http_request)       { instance_double(Net::HTTPRequest) }

  let(:plain_http_request) { HttpStub::Configurer::Request::PlainHttp.new(http_request) }

  describe "#to_http_request" do

    it "returns the provided HTTP request" do
      expect(plain_http_request.to_http_request).to eql(http_request)
    end

  end

end
