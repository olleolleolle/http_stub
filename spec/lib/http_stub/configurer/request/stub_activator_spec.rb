describe HttpStub::Configurer::Request::StubActivator do

  describe "#initialize" do

    context "when provided a payload" do

      let(:payload) { { payload_key: "payload value" } }

      let(:request) { HttpStub::Configurer::Request::StubActivator.new(payload) }

      it "creates a HTTP POST request" do
        expect(request.method).to eql("POST")
      end

      it "submits the request to '/stubs/activators'" do
        expect(request.path).to eql("/stubs/activators")
      end

      it "sets the content type to json" do
        expect(request.content_type).to eql("application/json")
      end

      it "sets the body to the JSON representation of the provided payload" do
        expect(request.body).to eql(payload.to_json)
      end

    end

  end

  describe "#activation_uri" do

    let(:activation_uri) { "http://some/activation/uri" }

    let(:request) { HttpStub::Configurer::Request::StubActivator.new(activation_uri: activation_uri) }

    it "should return the activation uri from the payload" do
      expect(request.activation_uri).to eql(activation_uri)
    end

  end

end
