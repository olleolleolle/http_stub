describe HttpStub::Server::Stub::Match::Rule::Headers do

  let(:stub_headers) { { "stub_key" => "value" } }

  let(:headers) { described_class.new(stub_headers) }

  it "is a hash with indifferent and insensitive access" do
    expect(headers).to be_a(HttpStub::Extensions::Core::Hash::IndifferentAndInsensitiveAccess)
  end

  context "when the stub header names contain hypens" do

    let(:stub_headers) { (1..3).each_with_object({}) { |i, result| result["stub-key-#{i}"] = "value-#{i}" } }

    it "underscores the names to accommodate for Rack Header manipulation" do
      expect(headers.keys).to eql(stub_headers.keys.map(&:underscore))
    end

    it "leaves the values unchanged" do
      expect(headers.values).to eql(stub_headers.values)
    end

  end

  context "when no headers are provided" do

    let(:stub_headers) { nil }

    it "is empty" do
      expect(headers.empty?).to be(true)
    end

  end

  describe "#matches?" do

    let(:request_headers) { instance_double(HttpStub::Server::Request::Headers) }
    let(:request)         { instance_double(HttpStub::Server::Request::Request, headers: request_headers) }
    let(:logger)          { double(Logger) }

    subject { headers.matches?(request, logger) }

    it "determines if the stub header and request header hashes match" do
      expect(HttpStub::Server::Stub::Match::HashMatcher).to receive(:match?).with(headers, request_headers)

      subject
    end

    it "returns the result of the match" do
      allow(HttpStub::Server::Stub::Match::HashMatcher).to receive(:match?).and_return(true)

      expect(subject).to eql(true)
    end

  end

  describe "#to_s" do

    subject { headers.to_s }

    describe "when multiple headers are provided" do

      let(:stub_headers) { (1..3).each_with_object({}) { |i, result| result["key#{i}"] = "value#{i}" } }

      it "returns a string with each header name and value separated by ':'" do
        result = subject

        stub_headers.each { |name, value| expect(result).to match(/#{name}:#{value}/) }
      end

      it "separates each header with comma for readability" do
        expect(subject).to match(/key\d.value\d, key\d.value\d, key\d.value\d/)
      end

    end

    describe "when empty headers are provided" do

      let(:stub_headers) { {} }

      it "returns an empty string" do
        expect(subject).to eql("")
      end

    end

    describe "when nil headers are provided" do

      let(:stub_headers) { nil }

      it "returns an empty string" do
        expect(subject).to eql("")
      end

    end

  end

end
