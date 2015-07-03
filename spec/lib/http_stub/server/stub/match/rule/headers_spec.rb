describe HttpStub::Server::Stub::Match::Rule::Headers do

  let(:request)         { instance_double(HttpStub::Server::Request) }

  let(:stubbed_headers) { { "stub_key" => "value" } }

  let(:request_headers) { described_class.new(stubbed_headers) }

  describe "when stubbed headers are provided" do

    it "creates a regexpable representation of the stubbed headers whose keys are downcased and underscored" do
      downcased_and_underscored_hash = { "another_stub_key" => "value" }
      expect(stubbed_headers).to receive(:downcase_and_underscore_keys).and_return(downcased_and_underscored_hash)
      expect(HttpStub::Server::Stub::Match::HashWithStringValueMatchers).to(
        receive(:new).with(downcased_and_underscored_hash)
      )

      request_headers
    end

  end

  describe "when the stubbed headers are nil" do

    let(:stubbed_headers) { nil }

    it "creates a regexpable representation of an empty hash" do
      expect(HttpStub::Server::Stub::Match::HashWithStringValueMatchers).to receive(:new).with({})

      request_headers
    end

  end

  describe "#matches?" do

    let(:request_header_hash)        { { "header_key" => "header value" } }
    let(:regexpable_stubbed_headers) do
      double(HttpStub::Server::Stub::Match::HashWithStringValueMatchers).as_null_object
    end
    let(:logger)                     { double(Logger) }

    subject { request_headers.matches?(request, logger) }

    before(:example) do
      allow(request).to receive(:headers).and_return(request_header_hash)
      allow(HttpStub::Server::Stub::Match::HashWithStringValueMatchers).to(
        receive(:new).and_return(regexpable_stubbed_headers)
      )
    end

    it "downcases and underscore the keys in the request header hash" do
      expect(request_header_hash).to receive(:downcase_and_underscore_keys)

      subject
    end

    it "delegates to the regexpable representation of the stubbed headers to determine a match" do
      downcased_and_underscored_hash = { "another_request_key" => "value" }
      allow(request_header_hash).to receive(:downcase_and_underscore_keys).and_return(downcased_and_underscored_hash)
      expect(regexpable_stubbed_headers).to receive(:matches?).with(downcased_and_underscored_hash).and_return(true)

      expect(subject).to eql(true)
    end

  end

  describe "#to_s" do

    let(:readable_hash) { instance_double(HttpStub::Server::FormattedHash, to_s: "readable header hash string") }

    subject { request_headers.to_s }

    before(:example) do
      allow(HttpStub::Server::FormattedHash).to receive(:new).with(stubbed_headers, anything).and_return(readable_hash)
    end

    it "returns the string representation of the readable header hash" do
      expect(subject).to eql("readable header hash string")
    end

    it "formats the headers with a ':' key value delimiter" do
      expect(HttpStub::Server::FormattedHash).to receive(:new).with(stubbed_headers, ":")

      subject
    end

  end

end
