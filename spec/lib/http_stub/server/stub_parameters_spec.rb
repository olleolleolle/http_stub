describe HttpStub::Server::StubParameters do

  let(:request_parameters) { double("RequestParameters") }
  let(:request) { double("HttpRequest", params: request_parameters) }

  let(:stubbed_parameters) { { "key1" => "value1", "key2" => "value2", "key3" => "value3" } }
  let(:regexpable_stubbed_paremeters) { double(HttpStub::Server::HashWithStringValueMatchers).as_null_object }

  let(:stub_parameters) { HttpStub::Server::StubParameters.new(stubbed_parameters) }

  describe "when stubbed parameters are provided" do

    it "creates a regexpable representation of the stubbed parameters" do
      expect(HttpStub::Server::HashWithStringValueMatchers).to receive(:new).with(stubbed_parameters)

      stub_parameters
    end

  end

  describe "when the stubbed parameters are nil" do

    let(:stubbed_parameters) { nil }

    it "creates a regexpable representation of an empty hash" do
      expect(HttpStub::Server::HashWithStringValueMatchers).to receive(:new).with({})

      stub_parameters
    end

  end

  describe "#match?" do

    it "delegates to the regexpable representation of the stubbed parameters to determine a match" do
      allow(HttpStub::Server::HashWithStringValueMatchers).to receive(:new).and_return(regexpable_stubbed_paremeters)
      expect(regexpable_stubbed_paremeters).to receive(:match?).with(request_parameters).and_return(true)

      expect(stub_parameters.match?(request)).to be(true)
    end

  end

  describe "#to_s" do

    describe "when multiple parameters are provided" do

      let(:stubbed_parameters) { { "key1" => "value1", "key2" => "value2", "key3" => "value3" } }

      it "returns a string containing each parameter formatted as a conventional request parameter" do
        result = stub_parameters.to_s

        stubbed_parameters.each { |key, value| expect(result).to match(/#{key}=#{value}/) }
      end

      it "separates each parameter with the conventional request parameter delimiter" do
        expect(stub_parameters.to_s).to match(/key\d.value\d\&key\d.value\d\&key\d.value\d/)
      end

    end

    describe "when empty parameters are provided" do

      let(:stubbed_parameters) { {} }

      it "returns an empty string" do
        expect(stub_parameters.to_s).to eql("")
      end

    end

    describe "when nil parameters are provided" do

      let(:stubbed_parameters) { nil }

      it "returns an empty string" do
        expect(stub_parameters.to_s).to eql("")
      end

    end

  end

end
