describe HttpStub::Configurer::DSL::ServerEndpointTemplate do

  let(:server)                    { instance_double(HttpStub::Configurer::DSL::Server) }
  let(:session_endpoint_template) { instance_double(HttpStub::Configurer::DSL::SessionEndpointTemplate) }
  let(:active_session)            do
    instance_double(HttpStub::Configurer::DSL::Session, endpoint_template: session_endpoint_template)
  end
  let(:initial_block_verifier)    { double("BlockVerifier") }
  let(:block)                     { lambda { initial_block_verifier.verify } }

  let(:server_endpoint_template) { described_class.new(server, active_session, &block) }

  before(:each) { }

  it "creates a session template in the active session that is initialized with the provided block" do
    expect(active_session).to receive(:endpoint_template).and_yield
    expect(initial_block_verifier).to receive(:verify)

    server_endpoint_template
  end

  describe "#match_requests" do

    let(:request_matching_rules) { { uri: "/some/stub/uri", method: :get } }

    subject { server_endpoint_template.match_requests(request_matching_rules) }

    it "delegates to the session template" do
      expect(session_endpoint_template).to receive(:match_requests).with(request_matching_rules)

      subject
    end

  end

  describe "#schema" do

    let(:type)       { :some_schema_type }
    let(:definition) { "some schema definition" }

    subject { server_endpoint_template.schema(type, definition) }

    it "delegates to the session template" do
      expect(session_endpoint_template).to receive(:schema).with(type, definition)

      subject
    end

    it "returns the created schema" do
      schema = { schema: :some_schema }
      expect(session_endpoint_template).to receive(:schema).and_return(schema)

      expect(subject).to eql(schema)
    end

  end

  describe "#respond_with" do

    let(:response_settings) { { status: 204 } }

    subject { server_endpoint_template.respond_with(response_settings) }

    it "delegates to the session templates" do
      expect(session_endpoint_template).to receive(:respond_with).with(response_settings)

      subject
    end

  end

  describe "#trigger" do

    let(:trigger_settings) { { scenario: "some scenario name" } }

    subject { server_endpoint_template.trigger(trigger_settings) }

    it "delegates to the session template" do
      expect(session_endpoint_template).to receive(:trigger).with(trigger_settings)

      subject
    end

  end

  describe "#invoke" do

    let(:block_verifier) { double("BlockVerifier") }
    let(:block)          { lambda { block_verifier.verify } }

    subject { server_endpoint_template.invoke(&block) }

    it "delegates to the session template" do
      expect(session_endpoint_template).to receive(:invoke).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

  end

  describe "#build_stub" do

    let(:response_overrides) { { status: 201 } }
    let(:block_verifier)     { double("BlockVerifier") }
    let(:block)              { lambda { block_verifier.verify } }

    subject { server_endpoint_template.build_stub(response_overrides, &block) }

    it "delegates to the session template" do
      expect(session_endpoint_template).to receive(:build_stub).with(response_overrides).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

  end

  describe "#add_stub!" do

    let(:response_overrides) { { status: 201 } }
    let(:block_verifier)     { double("BlockVerifier") }
    let(:block)              { lambda { block_verifier.verify } }

    subject { server_endpoint_template.add_stub!(response_overrides, &block) }

    it "delegates to the session template" do
      expect(session_endpoint_template).to receive(:add_stub!).with(response_overrides).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

  end

  describe "#add_scenario!" do

    let(:name)               { "Some scenario name" }
    let(:response_overrides) { { status: 201 } }
    let(:block_verifier)     { double("BlockVerifier") }
    let(:block)              { lambda { block_verifier.verify } }

    let(:stub_builder) { instance_double(HttpStub::Configurer::DSL::StubBuilder) }

    subject { server_endpoint_template.add_scenario!(name, response_overrides, &block) }

    before(:example) do
      allow(session_endpoint_template).to receive(:build_stub).and_return(stub_builder)
      allow(server).to receive(:add_scenario_with_one_stub!)
    end

    it "builds a stub using any provided response overrides and block" do
      expect(session_endpoint_template).to receive(:build_stub).with(response_overrides).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

    it "adds a one stub scenario to the server with the provided name and created stub builder" do
      expect(server).to receive(:add_scenario_with_one_stub!).with(name, stub_builder)

      subject
    end

  end

end
