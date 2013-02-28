describe HttpStub::Models::Stub do

  let(:stub_uri) { "/a_path" }
  let(:stub_method) { "get" }
  let(:stub_parameters) do
    { "param" => "value" }
  end
  let(:stub_options) do
    {
      "uri" => stub_uri,
      "method" => stub_method,
      "parameters" => stub_parameters,
      "response" => {
        "status" => 201,
        "body" => "Foo"
      }
    }
  end
  let(:the_stub) { HttpStub::Models::Stub.new(stub_options) }
  let(:parameters_model) { double(HttpStub::Models::Parameters, match?: true) }
  
  before(:each) { HttpStub::Models::Parameters.stub!(:new).and_return(parameters_model) }

  describe "#satisfies?" do

    let(:request_uri) { stub_uri }
    let(:request_method) { stub_method }
    let(:request) { double("HttpRequest", :path_info => request_uri, :request_method => request_method) }

    describe "when the request uri matches" do

      describe "and the request method matches" do

        describe "and a parameter match is configured" do
          
          describe "that matches" do
            
            before(:each) { parameters_model.stub!(:match?).with(request).and_return(true) }

            it "should return true" do
              the_stub.satisfies?(request).should be_true
            end
            
          end
          
          describe "that does not match" do

            before(:each) { parameters_model.stub!(:match?).with(request).and_return(false) }

            it "should return false" do
              the_stub.satisfies?(request).should be_false
            end

          end

        end

      end

    end

    describe "when the request uri does not match" do

      let(:request_uri) { "/a_different_path" }

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

  end

  describe "#uri" do

    it "should return the value provided in the request body" do
      the_stub.uri.should eql(stub_uri)
    end

  end

  describe "#method" do

    it "should return the value provided in the request body" do
      the_stub.method.should eql(stub_method)
    end

  end

  describe "#parameters" do

    it "should return the parameters model encapsulating the parameters provided in the request body" do
      the_stub.parameters.should eql(parameters_model)
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

    let(:stub_parameters) do
      {
          "param1" => "value1",
          "param2" => "value2",
          "param3" => "value3"
      }
    end

    it "should return a string containing the stubbed uri" do
      the_stub.to_s.should match(/\/a_path/)
    end

    it "should return a string containing the stubbed request method" do
      the_stub.to_s.should match(/get/)
    end

    it "should return a string containing the stubbed parameters" do
      stub_parameters.each_pair do |key, value|
        the_stub.to_s.should match(/#{Regexp.escape(key)}/)
        the_stub.to_s.should match(/#{Regexp.escape(value)}/)
      end
    end

    it "should return a string containing the intended response code" do
      the_stub.to_s.should match(/201/)
    end

    it "should return a string containing the intended response body" do
      the_stub.to_s.should match(/Foo/)
    end

  end

end
