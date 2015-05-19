describe HttpStub::Server::StubUri do

  let(:stubbed_uri) { "/some/uri" }
  let(:request) { double("HttpRequest", path_info: request_uri) }
  let(:value_matcher) { double(HttpStub::Server::StringValueMatcher).as_null_object }
  let(:stub_uri) { HttpStub::Server::StubUri.new(stubbed_uri) }

  before(:example) { allow(HttpStub::Server::StringValueMatcher).to receive(:new).and_return(value_matcher) }

  describe "constructor" do

    it "creates a value matcher for the provided uri" do
      expect(HttpStub::Server::StringValueMatcher).to receive(:new).with(stubbed_uri)

      stub_uri
    end

  end

  describe "#match?" do

    let(:request_uri) { "/some/uri" }

    it "delegates to the value matcher representation of the provided uri" do
      expect(value_matcher).to receive(:match?).with(request_uri).and_return(true)

      expect(stub_uri.match?(request)).to be_truthy
    end

  end

  describe "#to_s" do

    it "delegates to the value matcher representation of the provided uri" do
      expect(value_matcher).to receive(:to_s).and_return("some value matcher string")

      expect(stub_uri.to_s).to eql("some value matcher string")
    end

  end

end
