describe HttpStub::Models::StubHeaders do

  let(:request) { double("HttpRequest") }
  let(:stubbed_headers) { { "stub_key" => "value" } }

  let(:stub_headers) { HttpStub::Models::StubHeaders.new(stubbed_headers) }

  it "should be Headers" do
    stub_headers.should be_a(HttpStub::Models::Headers)
  end

  describe "when stubbed headers are provided" do

    it "should create a regexpable representation of the stubbed headers whose keys are downcased and underscored" do
      downcased_and_underscored_hash = { "another_stub_key" => "value" }
      stubbed_headers.should_receive(:downcase_and_underscore_keys).and_return(downcased_and_underscored_hash)
      HttpStub::Models::HashWithValueMatchers.should_receive(:new).with(downcased_and_underscored_hash)

      stub_headers
    end

  end

  describe "when the stubbed headers are nil" do

    let(:stubbed_headers) { nil }

    it "should create a regexpable representation of an empty hash" do
      HttpStub::Models::HashWithValueMatchers.should_receive(:new).with({})

      stub_headers
    end

  end

  describe "#match?" do

    let(:request_headers) { { "request_key" => "value" } }
    let(:regexpable_stubbed_headers) { double(HttpStub::Models::HashWithValueMatchers).as_null_object }

    before(:each) do
      HttpStub::Models::HashWithValueMatchers.stub(:new).and_return(regexpable_stubbed_headers)
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

end
