describe HttpStub::Server::Stub::Response::Headers do

  let(:header_hash) { HttpStub::HeadersFixture.many }

  let(:headers) { described_class.new(header_hash) }

  it "is a hash with indifferent access in order to support merging of headers regardless of type" do
    expect(headers).to be_a_kind_of(HashWithIndifferentAccess)
  end

  describe "::create" do

    let(:body) { HttpStub::Server::Stub::Response::TextBodyFixture.text }

    subject { described_class.create(header_hash, body) }

    context "when headers whose keys are symbols are provided" do

      let(:header_hash)      { HttpStub::HeadersFixture.many.symbolize_keys }
      let(:stringified_keys) { header_hash.keys.map(&:to_s) }

      it "returns headers containing the provided headers with keys converted to strings" do
        expect(subject.values_at(*stringified_keys)).to eql(header_hash.values)
      end

      it "returns headers containing the bodies headers" do
        expect(subject).to include(body.headers)
      end

    end

    context "when nil headers are provided" do

      let(:header_hash) { nil }

      it "creates headers containing only the bodies headers" do
        expect(subject).to eql(body.headers)
      end

    end

  end

  describe "constructor" do

    subject { headers }

    context "when headers whose keys are symbols are provided" do

      let(:header_hash)      { HttpStub::HeadersFixture.many.symbolize_keys }
      let(:stringified_keys) { header_hash.keys.map(&:to_s) }

      it "returns headers containing the provided headers with keys converted to strings" do
        expect(subject.values_at(*stringified_keys)).to eql(header_hash.values)
      end

    end

    context "when headers whose keys are strings are provided" do

      let(:header_hash) { HttpStub::HeadersFixture.many.stringify_keys }

      it "returns headers containing the provided headers" do
        expect(subject).to eql(header_hash)
      end

    end

  end

  describe "#to_s" do

    subject { headers.to_s }

    it "returns a string with each header name and value separated by ':'" do
      result = subject

      header_hash.each { |name, value| expect(result).to match(/#{name}:#{value}/) }
    end

    it "separates each header entry with a comma for readability" do
      expected_expression = header_hash.map { |name, value| "#{name}.#{value}" }.join(", ")

      expect(subject).to match(/#{expected_expression}/)
    end

  end

end
