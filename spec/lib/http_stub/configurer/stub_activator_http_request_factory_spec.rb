describe HttpStub::Configurer::StubActivatorHttpRequestFactory do

  let(:stub_factory) { HttpStub::Configurer::StubHttpRequestFactory }
  let(:factory) { HttpStub::Configurer::StubActivatorHttpRequestFactory }

  describe ".create" do

    let(:stub_request_body) { { key: "value" }.to_json }
    let(:stub_request) { double("HttpRequest", :body => stub_request_body) }

    before(:each) { stub_factory.stub!(:create).and_return(stub_request) }

    describe "when provided an activation uri, stub uri and stub options" do

      let(:activation_uri) { "Some activation URI" }
      let(:stub_uri) { "Some stub URI" }
      let(:stub_options) { "Some options" }

      it "should create a HTTP POST request" do
        request = factory.create(activation_uri, stub_uri, stub_options)

        request.class::METHOD.should eql("POST")
      end

      it "should submit the request to '/stubs/activators'" do
        request = factory.create(activation_uri, stub_uri, stub_options)

        request.path.should eql("/stubs/activators")
      end

      it "should set the content type to json" do
        request = factory.create(activation_uri, stub_uri, stub_options)

        request.content_type.should eql("application/json")
      end

      describe "generates a JSON body which" do

        it "should contain entries for a stub request" do
          stub_factory.should_receive(:create).with(stub_uri, stub_options).and_return(stub_request)

          request = factory.create(activation_uri, stub_uri, stub_options)

          JSON.parse(request.body).should include(JSON.parse(stub_request_body))
        end

        it "should have an entry for the provided activation URI" do
          request = factory.create(activation_uri, stub_uri, stub_options)

          JSON.parse(request.body).should include({ "activation_uri" => activation_uri })
        end

      end

    end

  end

end
