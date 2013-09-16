describe HttpStub::Models::StubHeaders do

  let(:request) { double("HttpRequest") }
  let(:stubbed_headers) { { "stub_key" => "value" } }

  let(:stub_headers) { HttpStub::Models::StubHeaders.new(stubbed_headers) }

  describe "when stubbed headers are provided" do

    it "should create a regexpable representation of the stubbed headers whose keys are downcased and underscored" do
      downcased_and_underscored_hash = { "another_stub_key" => "value" }
      stubbed_headers.should_receive(:downcase_and_underscore_keys).and_return(downcased_and_underscored_hash)
      HttpStub::Models::HashWithRegexpableValues.should_receive(:new).with(downcased_and_underscored_hash)

      stub_headers
    end

  end

  describe "when the stubbed headers are nil" do

    let(:stubbed_headers) { nil }

    it "should create a regexpable representation of an empty hash" do
      HttpStub::Models::HashWithRegexpableValues.should_receive(:new).with({})

      stub_headers
    end

  end

  describe "#match?" do

    let(:request_headers) { { "request_key" => "value" } }
    let(:regexpable_stubbed_headers) { double(HttpStub::Models::HashWithRegexpableValues).as_null_object }

    before(:each) do
      HttpStub::Models::HashWithRegexpableValues.stub(:new).and_return(regexpable_stubbed_headers)
      HttpStub::Models::RequestHeaderParser.stub(:parse).with(request).and_return(request_headers)
    end

    it "should parse the requests headers into a hash" do
      HttpStub::Models::RequestHeaderParser.should_receive(:parse).with(request).and_return(request_headers)

      stub_headers.match?(request)
    end

    it "should downcase and underscore the keys in the request header hash" do
      request_headers.should_receive(:downcase_and_underscore_keys)

      stub_headers.match?(request)
    end

    it "should delegate to the regexpable representation of the stubbed headers to determine a match" do
      downcased_and_underscored_hash = { "another_request_key" => "value" }
      request_headers.stub(:downcase_and_underscore_keys).and_return(downcased_and_underscored_hash)
      regexpable_stubbed_headers.should_receive(:match?).with(downcased_and_underscored_hash).and_return(true)

      stub_headers.match?(request).should be_true
    end

  end

  describe "#to_s" do

    describe "when multiple headers are provided" do

      let(:stubbed_headers) { { "key1" => "value1", "key2" => "value2", "key3" => "value3" } }

      it "should return a string containing each header formatted as a conventional request header" do
        result = stub_headers.to_s

        stubbed_headers.each { |key, value| result.should match(/#{key}:#{value}/) }
      end

      it "should comma delimit the headers" do
        stub_headers.to_s.should match(/key\d.value\d\, key\d.value\d\, key\d.value\d/)
      end

    end

    describe "when empty headers are provided" do

      let(:stubbed_headers) { {} }

      it "should return an empty string" do
        stub_headers.to_s.should eql("")
      end

    end

    describe "when nil headers are provided" do

      let(:stubbed_headers) { nil }

      it "should return an empty string" do
        stub_headers.to_s.should eql("")
      end

    end

  end

end
