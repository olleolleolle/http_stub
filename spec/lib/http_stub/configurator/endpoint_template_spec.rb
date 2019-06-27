describe HttpStub::Configurator::EndpointTemplate do

  let(:server)                 { instance_double(HttpStub::Configurator::Server) }
  let(:default_stub_template)  { instance_double(HttpStub::Configurator::Stub::Template) }
  let(:endpoint_stub_template) { instance_double(HttpStub::Configurator::Stub::Template) }
  let(:initial_block_verifier) { double("BlockVerifier") }
  let(:initial_block)          { lambda { initial_block_verifier.verify } }

  let(:server_endpoint_template) { described_class.new(server, default_stub_template, &initial_block) }

  before(:example) { allow(HttpStub::Configurator::Stub::Template).to receive(:new).and_return(endpoint_stub_template) }

  it "creates a stub template that is initialized with provided default stub template and block" do
    expect(HttpStub::Configurator::Stub::Template).to receive(:new).with(default_stub_template).and_yield
    expect(initial_block_verifier).to receive(:verify)

    server_endpoint_template
  end

  describe "#match_requests" do

    let(:request_matching_rules) { { uri: "/some/stub/uri", method: :get } }

    subject { server_endpoint_template.match_requests(request_matching_rules) }

    it "delegates to the endpoints stub template" do
      expect(endpoint_stub_template).to receive(:match_requests).with(request_matching_rules)

      subject
    end

  end

  describe "#schema" do

    let(:type)       { :some_schema_type }
    let(:definition) { "some schema definition" }

    subject { server_endpoint_template.schema(type, definition) }

    it "delegates to the endpoints stub template" do
      expect(endpoint_stub_template).to receive(:schema).with(type, definition)

      subject
    end

    it "returns the created schema" do
      schema = { schema: :some_schema }
      expect(endpoint_stub_template).to receive(:schema).and_return(schema)

      expect(subject).to eql(schema)
    end

  end

  describe "#respond_with" do

    let(:response_settings) { { status: 204 } }

    subject { server_endpoint_template.respond_with(response_settings) }

    it "delegates to the endpoints stub template" do
      expect(endpoint_stub_template).to receive(:respond_with).with(response_settings)

      subject
    end

  end

  describe "#trigger" do

    let(:trigger_settings) { { scenario: "some scenario name" } }

    subject { server_endpoint_template.trigger(trigger_settings) }

    it "delegates to the endpoints stub template" do
      expect(endpoint_stub_template).to receive(:trigger).with(trigger_settings)

      subject
    end

  end

  describe "#invoke" do

    let(:block_verifier) { double("BlockVerifier") }
    let(:block)          { lambda { block_verifier.verify } }

    subject { server_endpoint_template.invoke(&block) }

    it "delegates to the endpoints stub template" do
      expect(endpoint_stub_template).to receive(:invoke).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

  end

  describe "#build_stub" do

    let(:response_overrides) { { status: 201 } }
    let(:block_verifier)     { double("BlockVerifier") }
    let(:block)              { lambda { block_verifier.verify } }

    subject { server_endpoint_template.build_stub(response_overrides, &block) }

    it "delegates to the endpoints stub template" do
      expect(endpoint_stub_template).to receive(:build_stub).with(response_overrides).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

  end

  describe "#add_scenario!" do

    let(:name)               { "Some scenario name" }
    let(:response_overrides) { { status: 201 } }
    let(:block_verifier)     { double("BlockVerifier") }
    let(:block)              { lambda { block_verifier.verify } }

    let(:built_stub) { instance_double(HttpStub::Configurator::Stub::Stub) }

    subject { server_endpoint_template.add_scenario!(name, response_overrides, &block) }

    before(:example) do
      allow(endpoint_stub_template).to receive(:build_stub).and_return(built_stub)
      allow(server).to receive(:add_scenario_with_one_stub!)
    end

    it "builds a stub using any provided response overrides" do
      expect(endpoint_stub_template).to receive(:build_stub).with(response_overrides)

      subject
    end

    it "adds a one stub scenario to the server with the provided name, built stub and block" do
      expect(server).to receive(:add_scenario_with_one_stub!).with(name, built_stub).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

  end

  describe "#add_stub!" do

    let(:response_overrides) { { status: 201 } }
    let(:block_verifier)     { double("BlockVerifier") }
    let(:block)              { lambda { block_verifier.verify } }

    let(:built_stub) { instance_double(HttpStub::Configurator::Stub::Stub) }

    subject { server_endpoint_template.add_stub!(response_overrides, &block) }

    before(:example) do
      allow(endpoint_stub_template).to receive(:build_stub).and_return(built_stub)
      allow(server).to receive(:add_stub!)
    end

    it "builds a stub using any provided response overrides and block" do
      expect(endpoint_stub_template).to receive(:build_stub).with(response_overrides).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

    it "adds the built stub to the server" do
      expect(server).to receive(:add_stub!).with(built_stub)

      subject
    end

  end

end
