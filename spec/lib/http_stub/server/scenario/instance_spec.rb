describe HttpStub::Server::Scenario::Instance do

  let(:activation_uri)  { "/some/activation/uri" }
  let(:number_of_stubs) { 3 }
  let(:stubs)           { (1..number_of_stubs).map { instance_double(HttpStub::Server::Stub::Instance) } }
  let(:args) do
    HttpStub::ScenarioFixture.new.with_activation_uri!(activation_uri).with_stubs!(number_of_stubs).server_payload
  end

  let(:scenario) { HttpStub::Server::Scenario::Instance.new(args) }

  before(:example) { allow(HttpStub::Server::Stub).to receive(:create).and_return(*stubs) }

  describe "#constructor" do

    context "when many stubs payloads are provided" do

      let(:number_of_stubs) { 3 }

      it "creates an underlying stub for each stub payload provided" do
        args["stubs"].each { |stub_args| expect(HttpStub::Server::Stub).to receive(:create).with(stub_args) }

        scenario
      end

    end

    context "when one stub payload is provided" do

      let(:number_of_stubs) { 1 }

      it "creates an underlying stub for each stub payload provided" do
        expect(HttpStub::Server::Stub).to receive(:create).with(args["stubs"].first)

        scenario
      end

    end

  end

  describe "#satisfies?" do

    let(:request) { instance_double(Rack::Request, path_info: request_path_info) }

    describe "when the request uri exactly matches the scenario's activation uri" do

      let(:request_path_info) { activation_uri }

      it "returns true" do
        expect(scenario.satisfies?(request)).to be(true)
      end

    end

    describe "when the scenario's activation uri is a substring of the request uri" do

      let(:request_path_info) { "#{activation_uri}/with/additional/paths" }

      it "returns false" do
        expect(scenario.satisfies?(request)).to be(false)
      end

    end

    describe "when the request uri is completely different to the scenario's activation uri" do

      let(:request_path_info) { "/completely/different/path" }

      it "returns false" do
        expect(scenario.satisfies?(request)).to be(false)
      end

    end

  end

  describe "#stubs" do

    it "returns the HttpStub::Server::Stub's constructed from the scenario's arguments" do
      expect(scenario.stubs).to eql(stubs)
    end

  end

  describe "#activation_uri" do

    context "when the value provided in the payload contains a '/' prefix" do

      let(:activation_uri)  { "/has/forward/slash/prefix" }

      it "returns the value provided in the payload" do
        expect(scenario.activation_uri).to eql(activation_uri)
      end

    end

    context "when the value provided in the payload does not have a '/' prefix" do

      let(:activation_uri)  { "does/not/have/forward/slash/prefix" }

      it "returns the value provided in the payload prefixed with '/'" do
        expect(scenario.activation_uri).to eql("/#{activation_uri}")
      end

    end

  end

  describe "#to_s" do

    it "returns the string representation of the activation arguments" do
      expect(args).to receive(:to_s).and_return("scenario string representation")

      expect(scenario.to_s).to eql("scenario string representation")
    end

  end

end
