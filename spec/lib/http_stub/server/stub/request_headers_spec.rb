describe HttpStub::Server::Stub::RequestHeaders do

  let(:request)         { instance_double(Rack::Request) }
  let(:stubbed_headers) { { "stub_key" => "value" } }

  let(:request_headers) { HttpStub::Server::Stub::RequestHeaders.new(stubbed_headers) }

  it "is Headers" do
    expect(request_headers).to be_a(HttpStub::Server::Stub::Headers)
  end

  describe "when stubbed headers are provided" do

    it "creates a regexpable representation of the stubbed headers whose keys are downcased and underscored" do
      downcased_and_underscored_hash = { "another_stub_key" => "value" }
      expect(stubbed_headers).to receive(:downcase_and_underscore_keys).and_return(downcased_and_underscored_hash)
      expect(HttpStub::Server::Stub::HashWithStringValueMatchers).to receive(:new).with(downcased_and_underscored_hash)

      request_headers
    end

  end

  describe "when the stubbed headers are nil" do

    let(:stubbed_headers) { nil }

    it "creates a regexpable representation of an empty hash" do
      expect(HttpStub::Server::Stub::HashWithStringValueMatchers).to receive(:new).with({})

      request_headers
    end

  end

  describe "#match?" do

    let(:parsed_headers) { { "request_key" => "value" } }
    let(:regexpable_stubbed_headers) { double(HttpStub::Server::Stub::HashWithStringValueMatchers).as_null_object }

    before(:example) do
      allow(HttpStub::Server::Stub::HashWithStringValueMatchers).to receive(:new).and_return(regexpable_stubbed_headers)
      allow(HttpStub::Server::Stub::RequestHeaderParser).to receive(:parse).with(request).and_return(parsed_headers)
    end

    it "parses the requests headers into a hash" do
      expect(HttpStub::Server::Stub::RequestHeaderParser).to receive(:parse).with(request).and_return(parsed_headers)

      request_headers.match?(request)
    end

    it "downcases and underscore the keys in the request header hash" do
      expect(parsed_headers).to receive(:downcase_and_underscore_keys)

      request_headers.match?(request)
    end

    it "delegates to the regexpable representation of the stubbed headers to determine a match" do
      downcased_and_underscored_hash = { "another_request_key" => "value" }
      allow(parsed_headers).to receive(:downcase_and_underscore_keys).and_return(downcased_and_underscored_hash)
      expect(regexpable_stubbed_headers).to receive(:match?).with(downcased_and_underscored_hash).and_return(true)

      expect(request_headers.match?(request)).to be_truthy
    end

  end

end
