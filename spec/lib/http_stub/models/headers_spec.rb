describe HttpStub::Models::Headers do

  let(:header_hash) { {} }

  let(:headers) { HttpStub::Models::Headers.new(header_hash) }

  it "should be a Hash" do
    headers.should be_a(Hash)
  end

  describe "#to_s" do

    describe "when multiple headers are provided" do

      let(:header_hash) { { "key1" => "value1", "key2" => "value2", "key3" => "value3" } }

      it "should return a string containing each header formatted as a conventional request header" do
        result = headers.to_s

        header_hash.each { |key, value| result.should match(/#{key}:#{value}/) }
      end

      it "should comma delimit the headers" do
        headers.to_s.should match(/key\d.value\d\, key\d.value\d\, key\d.value\d/)
      end

    end

    describe "when empty headers are provided" do

      let(:header_hash) { {} }

      it "should return an empty string" do
        headers.to_s.should eql("")
      end

    end

    describe "when nil headers are provided" do

      let(:header_hash) { nil }

      it "should return an empty string" do
        headers.to_s.should eql("")
      end

    end

  end

end
