describe HttpStub::Server::Stub::Uri do

  let(:raw_uri)       { "/some/uri" }
  let(:value_matcher) { instance_double(HttpStub::Server::Stub::StringValueMatcher).as_null_object }

  let(:uri) { HttpStub::Server::Stub::Uri.new(raw_uri) }

  before(:example) { allow(HttpStub::Server::Stub::StringValueMatcher).to receive(:new).and_return(value_matcher) }

  describe "constructor" do

    it "creates a value matcher for the provided uri" do
      expect(HttpStub::Server::Stub::StringValueMatcher).to receive(:new).with(raw_uri)

      uri
    end

  end

  describe "#match?" do

    let(:request_uri) { "/some/uri" }
    let(:request)     { instance_double(Rack::Request, path_info: request_uri) }

    it "delegates to the value matcher representation of the provided uri" do
      expect(value_matcher).to receive(:match?).with(request_uri).and_return(true)

      expect(uri.match?(request)).to be(true)
    end

  end

  describe "#to_s" do

    it "delegates to the value matcher representation of the provided uri" do
      expect(value_matcher).to receive(:to_s).and_return("some value matcher string")

      expect(uri.to_s).to eql("some value matcher string")
    end

  end

end
