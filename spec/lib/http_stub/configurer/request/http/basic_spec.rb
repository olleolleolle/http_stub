describe HttpStub::Configurer::Request::Http::Basic do

  let(:http_request)  { instance_double(Net::HTTPRequest) }

  let(:basic_request) { HttpStub::Configurer::Request::Http::Basic.new(http_request) }

  describe "#to_http_request" do

    it "returns the provided HTTP request" do
      expect(basic_request.to_http_request).to eql(http_request)
    end

  end

end
