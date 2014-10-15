describe HttpStub::Models::StubActivator do

  let(:activation_uri) { "/some/activation/uri" }
  let(:args) do
    { "activation_uri" => activation_uri }
  end
  let(:stub_activator) { HttpStub::Models::StubActivator.new(args) }

  before(:example) { allow(HttpStub::Models::Stub).to receive(:new).and_return(double(HttpStub::Models::Stub)) }

  describe "#satisfies?" do

    let(:request) { double("HttpRequest", path_info: request_path_info) }

    describe "when the request uri exactly matches the activator's activation uri" do

      let(:request_path_info) { activation_uri }

      it "returns true" do
        expect(stub_activator.satisfies?(request)).to be_truthy
      end

    end

    describe "when the activator's activation uri is a substring of the request uri" do

      let(:request_path_info) { "#{activation_uri}/with/additional/paths" }

      it "returns false" do
        expect(stub_activator.satisfies?(request)).to be_falsey
      end

    end

    describe "when the request uri is completely different to the activator's activation uri" do

      let(:request_path_info) { "/completely/different/path" }

      it "returns false" do
        expect(stub_activator.satisfies?(request)).to be_falsey
      end

    end

  end

  describe "#the_stub" do

    it "returns a HttpStub::Models::Stub constructed from the activator's arguments" do
      stub = double(HttpStub::Models::Stub)
      expect(HttpStub::Models::Stub).to receive(:new).with(args).and_return(stub)

      expect(stub_activator.the_stub).to eql(stub)
    end

  end

  describe "#activation_uri" do

    it "returns the value provided in the request body" do
      expect(stub_activator.activation_uri).to eql(activation_uri)
    end

  end

  describe "#to_s" do

    it "returns the string representation of the activation arguments" do
      expect(args).to receive(:to_s).and_return("activation args string")

      expect(stub_activator.to_s).to eql("activation args string")
    end

  end

end
