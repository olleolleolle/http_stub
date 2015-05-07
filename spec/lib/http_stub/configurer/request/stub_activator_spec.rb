describe HttpStub::Configurer::Request::StubActivator do

  describe "#to_http_request" do

    let(:payload) { { some_key: "some value" } }

    let(:stub_activator_request) { HttpStub::Configurer::Request::StubActivator.new(payload) }

    subject { stub_activator_request.to_http_request }

    it "creates a HTTP POST request" do
      expect(subject.method).to eql("POST")
    end

    it "creates a request whose path is '/stubs/activators'" do
      expect(subject.path).to eql("/stubs/activators")
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

  describe "#activation_uri" do

    let(:activation_uri) { "http://some/activation/uri" }

    let(:stub_activator_request) { HttpStub::Configurer::Request::StubActivator.new(activation_uri: activation_uri) }

    it "should return the activation uri from the payload" do
      expect(stub_activator_request.activation_uri).to eql(activation_uri)
    end

  end

end
