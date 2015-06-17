describe HttpStub::Server::Stub::SimpleRequestBody do

  let(:raw_body)      { "some body" }
  let(:value_matcher) { instance_double(HttpStub::Server::Stub::StringValueMatcher).as_null_object }

  let(:simple_request_body) { HttpStub::Server::Stub::SimpleRequestBody.new(raw_body) }

  before(:example) { allow(HttpStub::Server::Stub::StringValueMatcher).to receive(:new).and_return(value_matcher) }

  describe "constructor" do

    it "creates a value matcher for the provided body" do
      expect(HttpStub::Server::Stub::StringValueMatcher).to receive(:new).with(raw_body)

      simple_request_body
    end

  end

  describe "#match?" do

    let(:request_body) { "some request body" }
    let(:request)      { instance_double(Rack::Request, body: double("Rack::Body", read: request_body)) }

    it "delegates to the value matcher to match the request body" do
      expect(value_matcher).to receive(:match?).with(request_body).and_return(true)

      expect(simple_request_body.match?(request)).to be(true)
    end

  end

  describe "#to_s" do

    it "delegates to the value matcher representation of the provided body" do
      expect(value_matcher).to receive(:to_s).and_return("some value matcher string")

      expect(simple_request_body.to_s).to eql("some value matcher string")
    end

  end

end
