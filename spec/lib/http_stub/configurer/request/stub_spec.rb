describe HttpStub::Configurer::Request::Stub do

  describe "#to_http_request" do

    let(:payload) { { some_key: "some value" } }

    let(:stub_request) { HttpStub::Configurer::Request::Stub.new(payload) }

    subject { stub_request.to_http_request }

    it "creates a HTTP POST request" do
      expect(subject.method).to eql("POST")
    end

    it "creates request whose path is '/stubs'" do
      expect(subject.path).to eql("/stubs")
    end

    it "creates a request whose content type is multipart" do
      expect(subject.content_type).to eql("multipart/form-data")
    end

    it "creates a request with a payload parameter that contains the JSON representation of the provided payload" do
      body = subject.body_stream.read

      expect(body).to include("payload")
      expect(body).to include(payload.to_json)
    end

  end

  describe "#stub_uri" do

    let(:stub_uri) { "/some/stub/uri" }

    let(:stub_request) { HttpStub::Configurer::Request::Stub.new(uri: stub_uri) }

    it "should return the uri from the payload" do
      expect(stub_request.stub_uri).to eql(stub_uri)
    end

  end

end
