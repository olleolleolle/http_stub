describe HttpStub::Models::StubUri do

  let(:stubbed_uri) { "/some/uri" }
  let(:request) { double("HttpRequest", path_info: request_uri) }
  let(:value_matcher) { double(HttpStub::Models::StringValueMatcher).as_null_object }
  let(:stub_uri) { HttpStub::Models::StubUri.new(stubbed_uri) }

  before(:each) { HttpStub::Models::StringValueMatcher.stub(:new).and_return(value_matcher) }

  describe "constructor" do

    it "should create a value matcher for the provided uri" do
      HttpStub::Models::StringValueMatcher.should_receive(:new).with(stubbed_uri)

      stub_uri
    end

  end

  describe "#match?" do

    let(:request_uri) { "/some/uri" }

    it "should delegate to the value matcher representation of the provided uri" do
      value_matcher.should_receive(:match?).with(request_uri).and_return(true)

      stub_uri.match?(request).should be_true
    end

  end

  describe "#to_s" do

    it "should delegate to the value matcher representation of the provided uri" do
      value_matcher.should_receive(:to_s).and_return("some value matcher string")

      stub_uri.to_s.should eql("some value matcher string")
    end

  end

end
