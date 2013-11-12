describe HttpStub::Models::StubParameters do

  let(:request_parameters) { double("RequestParameters") }
  let(:request) { double("HttpRequest", params: request_parameters) }

  let(:stubbed_parameters) { { "key1" => "value1", "key2" => "value2", "key3" => "value3" } }
  let(:regexpable_stubbed_paremeters) { double(HttpStub::Models::HashWithValueMatchers).as_null_object }

  let(:stub_parameters) { HttpStub::Models::StubParameters.new(stubbed_parameters) }

  describe "when stubbed parameters are provided" do

    it "should create a regexpable representation of the stubbed parameters" do
      HttpStub::Models::HashWithValueMatchers.should_receive(:new).with(stubbed_parameters)

      stub_parameters
    end

  end

  describe "when the stubbed parameters are nil" do

    let(:stubbed_parameters) { nil }

    it "should create a regexpable representation of an empty hash" do
      HttpStub::Models::HashWithValueMatchers.should_receive(:new).with({})

      stub_parameters
    end

  end

  describe "#match?" do

    it "should delegate to the regexpable representation of the stubbed parameters to determine a match" do
      HttpStub::Models::HashWithValueMatchers.stub(:new).and_return(regexpable_stubbed_paremeters)
      regexpable_stubbed_paremeters.should_receive(:match?).with(request_parameters).and_return(true)

      stub_parameters.match?(request).should be(true)
    end

  end

  describe "#to_s" do

    describe "when multiple parameters are provided" do

      let(:stubbed_parameters) { { "key1" => "value1", "key2" => "value2", "key3" => "value3" } }

      it "should return a string containing each parameter formatted as a conventional request parameter" do
        result = stub_parameters.to_s

        stubbed_parameters.each { |key, value| result.should match(/#{key}=#{value}/) }
      end

      it "should separate each parameter with the conventional request parameter delimiter" do
        stub_parameters.to_s.should match(/key\d.value\d\&key\d.value\d\&key\d.value\d/)
      end

    end

    describe "when empty parameters are provided" do

      let(:stubbed_parameters) { {} }

      it "should return an empty string" do
        stub_parameters.to_s.should eql("")
      end

    end

    describe "when nil parameters are provided" do

      let(:stubbed_parameters) { nil }

      it "should return an empty string" do
        stub_parameters.to_s.should eql("")
      end

    end

  end

end
