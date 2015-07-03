describe HttpStub::Server::Stub::Match::Rule::SimpleBody do

  let(:raw_body)      { "some body" }
  let(:value_matcher) { instance_double(HttpStub::Server::Stub::Match::StringValueMatcher).as_null_object }

  let(:simple_body) { described_class.new(raw_body) }

  before(:example) do
    allow(HttpStub::Server::Stub::Match::StringValueMatcher).to receive(:new).and_return(value_matcher)
  end

  describe "constructor" do

    it "creates a value matcher for the provided body" do
      expect(HttpStub::Server::Stub::Match::StringValueMatcher).to receive(:new).with(raw_body)

      simple_body
    end

  end

  describe "#matches?" do

    let(:request_body) { "some request body" }
    let(:request)      { instance_double(HttpStub::Server::Request, body: request_body) }
    let(:logger)       { instance_double(Logger) }

    it "delegates to the value matcher to match the request body" do
      expect(value_matcher).to receive(:matches?).with(request_body).and_return(true)

      expect(simple_body.matches?(request, logger)).to be(true)
    end

  end

  describe "#to_s" do

    it "delegates to the value matcher representation of the provided body" do
      expect(value_matcher).to receive(:to_s).and_return("some value matcher string")

      expect(simple_body.to_s).to eql("some value matcher string")
    end

  end

end
