describe HttpStub::Server::Stub::Match::Rule::Parameters do

  let(:raw_request_parameters) { double("RequestParameters") }
  let(:request)                { instance_double(HttpStub::Server::Request, parameters: raw_request_parameters) }

  let(:stubbed_parameters)            { { "key1" => "value1", "key2" => "value2", "key3" => "value3" } }
  let(:regexpable_stubbed_paremeters) do
    double(HttpStub::Server::Stub::Match::HashWithStringValueMatchers).as_null_object
  end

  let(:request_parameters) { described_class.new(stubbed_parameters) }

  describe "when stubbed parameters are provided" do

    it "creates a regexpable representation of the stubbed parameters" do
      expect(HttpStub::Server::Stub::Match::HashWithStringValueMatchers).to receive(:new).with(stubbed_parameters)

      request_parameters
    end

  end

  describe "when the stubbed parameters are nil" do

    let(:stubbed_parameters) { nil }

    it "creates a regexpable representation of an empty hash" do
      expect(HttpStub::Server::Stub::Match::HashWithStringValueMatchers).to receive(:new).with({})

      request_parameters
    end

  end

  describe "#matches?" do

    let(:logger) { instance_double(Logger) }

    it "delegates to the regexpable representation of the stubbed parameters to determine a match" do
      allow(HttpStub::Server::Stub::Match::HashWithStringValueMatchers).to(
        receive(:new).and_return(regexpable_stubbed_paremeters)
      )
      expect(regexpable_stubbed_paremeters).to receive(:matches?).with(raw_request_parameters).and_return(true)

      expect(request_parameters.matches?(request, logger)).to be(true)
    end

  end

  describe "#to_s" do

    subject { request_parameters.to_s }

    describe "when multiple parameters are provided" do

      let(:stubbed_parameters) { { "key1" => "value1", "key2" => "value2", "key3" => "value3" } }

      it "returns a string containing each parameter formatted as a conventional request parameter" do
        result = subject

        stubbed_parameters.each { |key, value| expect(result).to match(/#{key}=#{value}/) }
      end

      it "separates each parameter with the conventional request parameter delimiter" do
        expect(subject).to match(/key\d.value\d\&key\d.value\d\&key\d.value\d/)
      end

    end

    describe "when empty parameters are provided" do

      let(:stubbed_parameters) { {} }

      it "returns an empty string" do
        expect(subject).to eql("")
      end

    end

    describe "when nil parameters are provided" do

      let(:stubbed_parameters) { nil }

      it "returns an empty string" do
        expect(subject).to eql("")
      end

    end

  end

end
