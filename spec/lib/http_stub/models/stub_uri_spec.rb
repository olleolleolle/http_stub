describe HttpStub::Models::StubUri do

  let(:stubbed_uri) { "/some/uri" }
  let(:request) { double("HttpRequest", path_info: request_uri) }
  let(:regexpable_value) { double(HttpStub::Models::RegexpableValue).as_null_object }
  let(:stub_uri) { HttpStub::Models::StubUri.new(stubbed_uri) }

  before(:each) { HttpStub::Models::RegexpableValue.stub!(:new).and_return(regexpable_value) }

  describe "constructor" do

    it "should create a regexpable representation of the provided uri" do
      HttpStub::Models::RegexpableValue.should_receive(:new).with(stubbed_uri)

      stub_uri
    end

  end

  describe "#match?" do

    let(:request_uri) { "/some/uri" }

    it "should delegate to the regexpable representation of the provided uri" do
      regexpable_value.should_receive(:match?).with(request_uri).and_return(true)

      stub_uri.match?(request).should be_true
    end

  end

  describe "#to_s" do

    it "should delegate to the regexpable representation of the provided uri" do
      regexpable_value.should_receive(:to_s).and_return("some regexpable value string")

      stub_uri.to_s.should eql("some regexpable value string")
    end

  end

end
