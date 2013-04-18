describe HttpStub::Models::Stub do

  let(:raw_stub_headers) do
    {
        "header1" => "header_value1",
        "header2" => "header_value2",
        "header3" => "header_value3"
    }
  end
  let(:raw_stub_parameters) do
    {
        "param1" => "param_value1",
        "param2" => "param_value2",
        "param3" => "param_value3"
    }
  end
  let(:stub_method) { "get" }
  let(:stub_options) do
    {
      "uri" => "/a_path",
      "method" => stub_method,
      "headers" => raw_stub_headers,
      "parameters" => raw_stub_parameters,
      "response" => {
        "status" => 201,
        "body" => "Foo"
      }
    }
  end
  let(:stub_uri) { double(HttpStub::Models::StubUri, match?: true) }
  let(:stub_parameters) { double(HttpStub::Models::StubParameters, match?: true) }
  let(:stub_headers) { double(HttpStub::Models::StubHeaders, match?: true) }

  let(:the_stub) { HttpStub::Models::Stub.new(stub_options) }

  before(:each) do
    HttpStub::Models::StubUri.stub!(:new).and_return(stub_uri)
    HttpStub::Models::StubParameters.stub!(:new).and_return(stub_parameters)
    HttpStub::Models::StubHeaders.stub!(:new).and_return(stub_headers)
  end

  describe "#satisfies?" do

    let(:request_uri) { "/a_request_uri" }
    let(:request_method) { stub_method }
    let(:request) { double("HttpRequest", :request_method => request_method) }

    describe "when the request uri matches" do

      before(:each) { stub_uri.stub!(:match?).with(request).and_return(true) }

      describe "and the request method matches" do

        describe "and a header match is configured" do

          describe "that matches" do

            before(:each) { stub_headers.stub!(:match?).with(request).and_return(true) }

            describe "and a parameter match is configured" do

              describe "that matches" do

                before(:each) { stub_parameters.stub!(:match?).with(request).and_return(true) }

                it "should return true" do
                  the_stub.satisfies?(request).should be_true
                end

              end

            end

          end

        end

      end

    end

    describe "when the request uri does not match" do

      before(:each) { stub_uri.stub!(:match?).with(request).and_return(false) }

      it "should return false" do
        the_stub.satisfies?(request).should be_false
      end

    end

    describe "when the request method does not match" do

      let(:request_method) { "post" }

      it "should return false" do
        the_stub.satisfies?(request).should be_false
      end

    end

    describe "when the headers do not match" do

      before(:each) { stub_headers.stub!(:match?).with(request).and_return(false) }

      it "should return false" do
        the_stub.satisfies?(request).should be_false
      end

    end

    describe "when the parameters do not match" do

      before(:each) { stub_parameters.stub!(:match?).with(request).and_return(false) }

      it "should return false" do
        the_stub.satisfies?(request).should be_false
      end

    end

  end

  describe "#uri" do

    it "should return the parameters model encapsulating the uri provided in the request body" do
      the_stub.uri.should eql(stub_uri)
    end

  end

  describe "#method" do

    it "should return the value provided in the request body" do
      the_stub.method.should eql(stub_method)
    end

  end

  describe "#headers" do

    it "should return the headers model encapsulating the headers provided in the request body" do
      the_stub.headers.should eql(stub_headers)
    end

  end

  describe "#parameters" do

    it "should return the parameters model encapsulating the parameters provided in the request body" do
      the_stub.parameters.should eql(stub_parameters)
    end

  end

  describe "#response" do

    it "should expose the provided response status" do
      the_stub.response.status.should eql(201)
    end

    it "should expose the provided response body" do
      the_stub.response.body.should eql("Foo")
    end

  end

  describe "#to_s" do

    it "should return a string representation of the stub options" do
      stub_options.should_receive(:to_s).and_return("stub options string")

      the_stub.to_s.should eql("stub options string")
    end
  end

end
