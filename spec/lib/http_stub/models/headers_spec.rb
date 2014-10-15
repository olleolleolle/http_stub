describe HttpStub::Models::Headers do

  let(:header_hash) { {} }

  let(:headers) { HttpStub::Models::Headers.new(header_hash) }

  it "is a Hash" do
    expect(headers).to be_a(Hash)
  end

  describe "#to_s" do

    describe "when multiple headers are provided" do

      let(:header_hash) { { "key1" => "value1", "key2" => "value2", "key3" => "value3" } }

      it "returns a string containing each header formatted as a conventional request header" do
        result = headers.to_s

        header_hash.each { |key, value| expect(result).to match(/#{key}:#{value}/) }
      end

      it "comma delimits the headers" do
        expect(headers.to_s).to match(/key\d.value\d\, key\d.value\d\, key\d.value\d/)
      end

    end

    describe "when empty headers are provided" do

      let(:header_hash) { {} }

      it "returns an empty string" do
        expect(headers.to_s).to eql("")
      end

    end

    describe "when nil headers are provided" do

      let(:header_hash) { nil }

      it "returns an empty string" do
        expect(headers.to_s).to eql("")
      end

    end

  end

end
