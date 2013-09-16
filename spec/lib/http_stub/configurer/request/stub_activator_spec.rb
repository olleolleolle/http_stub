describe HttpStub::Configurer::Request::StubActivator do

  describe "#initialize" do

    let(:stub_request_body) { { key: "value" }.to_json }
    let(:stub_request_content_type) { "Some content type" }
    let(:stub_request) { double("StubRequest", :content_type => stub_request_content_type, :body => stub_request_body) }

    before(:each) { HttpStub::Configurer::Request::Stub.stub(:new).and_return(stub_request) }

    describe "when provided an activation uri, stub uri and stub options" do

      let(:activation_uri) { "Some activation URI" }
      let(:stub_uri) { "Some stub URI" }
      let(:stub_options) { "Some options" }

      let(:request) { HttpStub::Configurer::Request::StubActivator.new(activation_uri, stub_uri, stub_options) }
      let(:request_body) { JSON.parse(request.body) }

      it "should create a HTTP POST request" do
        request.method.should eql("POST")
      end

      it "should submit the request to '/stubs/activators'" do
        request.path.should eql("/stubs/activators")
      end

      it "should set the content type to the same as a stub request" do
        request.content_type.should eql(stub_request_content_type)
      end

      describe "generates a JSON body which" do

        it "should contain entries for a stub request" do
          HttpStub::Configurer::Request::Stub.should_receive(:new).with(stub_uri, stub_options).and_return(stub_request)

          request_body.should include(JSON.parse(stub_request_body))
        end

        it "should have an entry for the provided activation URI" do
          request_body.should include({ "activation_uri" => activation_uri })
        end

      end

    end

  end

end
