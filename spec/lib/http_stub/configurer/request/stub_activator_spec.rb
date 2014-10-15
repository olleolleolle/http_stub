describe HttpStub::Configurer::Request::StubActivator do

  describe "#initialize" do

    let(:stub_request_body) { { key: "value" }.to_json }
    let(:stub_request_content_type) { "Some content type" }
    let(:stub_request) { double("StubRequest", :content_type => stub_request_content_type, :body => stub_request_body) }

    before(:example) { allow(HttpStub::Configurer::Request::Stub).to receive(:new).and_return(stub_request) }

    describe "when provided an activation uri, stub uri and stub options" do

      let(:activation_uri) { "Some activation URI" }
      let(:stub_uri) { "Some stub URI" }
      let(:stub_options) { "Some options" }

      let(:request) { HttpStub::Configurer::Request::StubActivator.new(activation_uri, stub_uri, stub_options) }
      let(:request_body) { JSON.parse(request.body) }

      it "creates a HTTP POST request" do
        expect(request.method).to eql("POST")
      end

      it "submits the request to '/stubs/activators'" do
        expect(request.path).to eql("/stubs/activators")
      end

      it "sets the content type to the same as a stub request" do
        expect(request.content_type).to eql(stub_request_content_type)
      end

      describe "generates a JSON body which" do

        it "contains entries for a stub request" do
          expect(HttpStub::Configurer::Request::Stub).to receive(:new).with(stub_uri, stub_options).and_return(stub_request)

          expect(request_body).to include(JSON.parse(stub_request_body))
        end

        it "has an entry for the provided activation URI" do
          expect(request_body).to include({ "activation_uri" => activation_uri })
        end

      end

    end

  end

end
