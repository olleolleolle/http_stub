describe HttpStub::Server::Stub::Match::Rule::SimpleBody do

  let(:stub_body) { "some body" }

  let(:simple_body) { described_class.new(stub_body) }

  describe "#matches?" do

    let(:request_body) { "some request body" }
    let(:request)      { instance_double(HttpStub::Server::Request::Request, body: request_body) }
    let(:logger)       { instance_double(Logger) }

    subject { simple_body.matches?(request, logger) }

    it "determines if the stub uri  and request uri strings match" do
      expect(HttpStub::Server::Stub::Match::StringValueMatcher).to receive(:match?).with(stub_body, request_body)

      subject
    end

    it "returns the result of the match" do
      allow(HttpStub::Server::Stub::Match::StringValueMatcher).to receive(:match?).and_return(true)

      expect(subject).to eql(true)
    end

  end

  describe "#to_s" do

    it "returns the stub body" do
      expect(simple_body.to_s).to eql(stub_body)
    end

  end

end
