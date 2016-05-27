describe HttpStub::Server::Stub::Match::Rule::Uri do

  let(:stub_uri) { "/some/uri" }

  let(:uri) { described_class.new(stub_uri) }

  describe "#matches?" do

    let(:request_uri) { "/some/uri" }
    let(:request)     { instance_double(HttpStub::Server::Request::Request, uri: request_uri) }
    let(:logger)      { instance_double(Logger) }

    subject { uri.matches?(request, logger) }

    it "determines if the stub uri and request uri strings match" do
      expect(HttpStub::Server::Stub::Match::StringValueMatcher).to receive(:match?).with(stub_uri, request_uri)

      subject
    end

    it "returns the result of the match" do
      allow(HttpStub::Server::Stub::Match::StringValueMatcher).to receive(:match?).and_return(true)

      expect(subject).to eql(true)
    end

  end

  describe "#to_s" do

    it "returns the stub uri" do
      expect(uri.to_s).to eql(stub_uri)
    end

  end

end
