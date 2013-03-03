describe HttpStub::Models::StubActivator do

  let(:activation_uri) { "/some/activation/uri" }
  let(:options) do
    { "activation_uri" => activation_uri }
  end
  let(:stub_activator) { HttpStub::Models::StubActivator.new(options) }

  before(:each) { HttpStub::Models::Stub.stub!(:new).and_return(double(HttpStub::Models::Stub)) }

  describe "#satisfies?" do

    let(:request) { double("HttpRequest", path_info: request_path_info) }

    describe "when the request uri exactly matches the activator's activation uri" do

      let(:request_path_info) { activation_uri }

      it "should return true" do
        stub_activator.satisfies?(request).should be_true
      end

    end

    describe "when the activator's activation uri is a substring of the request uri" do

      let(:request_path_info) { "#{activation_uri}/with/additional/paths" }

      it "should return false" do
        stub_activator.satisfies?(request).should be_false
      end

    end

    describe "when the request uri is completely different to the activator's activation uri" do

      let(:request_path_info) { "/completely/different/path" }

      it "should return false" do
        stub_activator.satisfies?(request).should be_false
      end

    end

  end

  describe "#the_stub" do

    it "should return a HttpStub::Models::Stub constructed from the activator's options" do
      stub = double(HttpStub::Models::Stub)
      HttpStub::Models::Stub.should_receive(:new).with(options).and_return(stub)

      stub_activator.the_stub.should eql(stub)
    end

  end

  describe "#activation_uri" do

    it "should return the value provided in the request body" do
      stub_activator.activation_uri.should eql(activation_uri)
    end

  end

end
