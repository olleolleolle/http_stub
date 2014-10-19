describe HttpStub::Configurer::Request::Stub do

  describe "#initialize" do

    context "when provided a payload" do

      let(:payload) { { payload_key: "payload value" } }

      let(:request) { HttpStub::Configurer::Request::Stub.new(payload) }

      it "creates a HTTP POST request" do
        expect(request.method).to eql("POST")
      end

      it "submits the request to '/stubs'" do
        expect(request.path).to eql("/stubs")
      end

      it "sets the content type to json" do
        expect(request.content_type).to eql("application/json")
      end

      it "sets the body to the JSON representation of the provided payload" do
        expect(request.body).to eql(payload.to_json)
      end

    end

  end

  describe "#stub_uri" do

    let(:stub_uri) { "/some/stub/uri" }

    let(:request) { HttpStub::Configurer::Request::Stub.new(uri: stub_uri) }

    it "should return the uri from the payload" do
      expect(request.stub_uri).to eql(stub_uri)
    end

  end

end
