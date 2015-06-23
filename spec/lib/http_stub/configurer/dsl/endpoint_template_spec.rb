describe HttpStub::Configurer::DSL::EndpointTemplate do

  let(:stub_fixture) { HttpStub::StubFixture.new }

  let(:server)               { instance_double(HttpStub::Configurer::DSL::Server) }
  let(:response_defaults)    { {} }
  let(:default_stub_builder) { instance_double(HttpStub::Configurer::DSL::StubBuilder) }

  let(:endpoint_template) { HttpStub::Configurer::DSL::EndpointTemplate.new(server, response_defaults) }

  before(:example) do
    allow(HttpStub::Configurer::DSL::StubBuilder).to(
      receive(:new).with(response_defaults).and_return(default_stub_builder)
    )
  end

  describe "#match_requests" do

    let(:uri)  { "/some/uri" }
    let(:args) { { key: :value } }

    subject { endpoint_template.match_requests(uri, args) }

    it "delegates to the default stub builder" do
      expect(default_stub_builder).to receive(:match_requests).with(uri, args)

      subject
    end

  end

  describe "#schema" do

    let(:type)       { :some_type }
    let(:definition) { { key: :value } }

    subject { endpoint_template.schema(type, definition) }

    it "delegates to the default stub builder" do
      expect(default_stub_builder).to receive(:schema).with(type, definition)

      subject
    end

  end

  describe "#respond_with" do

    let(:args) { { status: 204 } }

    subject { endpoint_template.respond_with(args) }

    it "delegates to the default stub builder" do
      expect(default_stub_builder).to receive(:respond_with).with(args)

      subject
    end

  end

  describe "#trigger" do

    let(:trigger) { instance_double(HttpStub::Configurer::DSL::StubBuilder) }

    subject { endpoint_template.trigger(trigger) }

    it "delegates to the default stub builder" do
      expect(default_stub_builder).to receive(:trigger).with(trigger)

      subject
    end

  end

  describe "#invoke" do

    let(:block_verifier) { double("BlockVerifier") }
    let(:block)          { lambda { block_verifier.verify } }

    subject { endpoint_template.invoke(&block) }

    it "delegates to the default stub builder" do
      expect(default_stub_builder).to receive(:invoke).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

  end

  describe "#add_scenario!" do

    let(:name)               { "some_scenario_name" }
    let(:response_overrides) { {} }
    let(:block_verifier)     { double("BlockVerifier") }
    let(:block)              { lambda { block_verifier.verify } }

    let(:stub_builder)     { instance_double(HttpStub::Configurer::DSL::StubBuilder).as_null_object }

    before(:example) { allow(server).to receive(:add_one_stub_scenario!).and_yield(stub_builder) }

    subject { endpoint_template.add_scenario!(name, response_overrides, &block) }

    it "add a one stub scenario to the server" do
      expect(server).to receive(:add_one_stub_scenario!).with(name)

      subject
    end

    it "merges the added stub with the default stub builder" do
      expect(stub_builder).to receive(:merge!).with(default_stub_builder)

      subject
    end

    context "when response overrides are provided" do

      let(:response_overrides) { { status: 302 } }

      it "informs the stub builder to respond with the response overrides" do
        expect(stub_builder).to receive(:respond_with).with(response_overrides)

        subject
      end

    end

    context "when response overrides are not provided" do

      subject { endpoint_template.add_scenario!(name, &block) }

      it "does not change the stub builder by requesting it respond with an empty hash" do
        expect(stub_builder).to receive(:respond_with).with({})

        subject
      end

    end

    it "merges the response defaults before applying the response overrides" do
      expect(stub_builder).to receive(:merge!).ordered
      expect(stub_builder).to receive(:respond_with).ordered

      subject
    end

    it "requests the added stub builder invoke the provided block" do
      expect(stub_builder).to receive(:invoke).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

    it "applies the response overrides before invoking the provided block" do
      expect(stub_builder).to receive(:respond_with).ordered
      expect(stub_builder).to receive(:invoke).ordered

      subject
    end

  end

end
