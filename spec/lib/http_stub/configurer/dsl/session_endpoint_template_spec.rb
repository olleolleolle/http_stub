describe HttpStub::Configurer::DSL::SessionEndpointTemplate do

  let(:session)                { instance_double(HttpStub::Configurer::DSL::Session) }
  let(:default_stub_template)  { instance_double(HttpStub::Configurer::DSL::StubBuilderTemplate) }
  let(:initial_block_verifier) { double("BlockVerifier") }
  let(:block)                  { lambda { initial_block_verifier.verify } }

  let(:session_stub_template) { instance_double(HttpStub::Configurer::DSL::StubBuilderTemplate) }

  let(:session_endpoint_template) { described_class.new(session, default_stub_template, &block) }

  before(:each) do
    allow(HttpStub::Configurer::DSL::StubBuilderTemplate).to receive(:new).and_return(session_stub_template)
  end

  it "creates a stub template that extends the default template and is initialized with the provided block" do
    expect(HttpStub::Configurer::DSL::StubBuilderTemplate).to receive(:new).with(default_stub_template).and_yield
    expect(initial_block_verifier).to receive(:verify)

    session_endpoint_template
  end

  describe "#match_requests" do

    let(:request_matching_rules) { { uri: "/some/stub/uri", method: :get } }

    subject { session_endpoint_template.match_requests(request_matching_rules) }

    it "delegates to the sessions stub template" do
      expect(session_stub_template).to receive(:match_requests).with(request_matching_rules)

      subject
    end

  end

  describe "#schema" do

    let(:type)       { :some_schema_type }
    let(:definition) { "some schema definition" }

    subject { session_endpoint_template.schema(type, definition) }

    it "delegates to the sessions stub template" do
      expect(session_stub_template).to receive(:schema).with(type, definition)

      subject
    end

    it "returns the created schema" do
      schema = { schema: :some_schema }
      expect(session_stub_template).to receive(:schema).and_return(schema)

      expect(subject).to eql(schema)
    end

  end

  describe "#respond_with" do

    let(:response_settings) { { status: 204 } }

    subject { session_endpoint_template.respond_with(response_settings) }

    it "delegates to the sessions stub template" do
      expect(session_stub_template).to receive(:respond_with).with(response_settings)

      subject
    end

  end

  describe "#trigger" do

    let(:trigger_settings) { { scenario: "some scenario name" } }

    subject { session_endpoint_template.trigger(trigger_settings) }

    it "delegates to the sessions stub template" do
      expect(session_stub_template).to receive(:trigger).with(trigger_settings)

      subject
    end

  end

  describe "#invoke" do

    let(:block_verifier) { double("BlockVerifier") }
    let(:block)          { lambda { block_verifier.verify } }

    subject { session_endpoint_template.invoke(&block) }

    it "delegates to the sessions stub template" do
      expect(session_stub_template).to receive(:invoke).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

  end

  describe "#build_stub" do

    let(:response_overrides) { { status: 201 } }
    let(:block_verifier)     { double("BlockVerifier") }
    let(:block)              { lambda { block_verifier.verify } }

    subject { session_endpoint_template.build_stub(response_overrides, &block) }

    it "delegates to the sessions stub template" do
      expect(session_stub_template).to receive(:build_stub).with(response_overrides).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

  end

  describe "#add_stub!" do

    let(:response_overrides) { { status: 201 } }
    let(:block_verifier)     { double("BlockVerifier") }
    let(:block)              { lambda { block_verifier.verify } }

    let(:stub_builder) { instance_double(HttpStub::Configurer::DSL::StubBuilder) }

    subject { session_endpoint_template.add_stub!(response_overrides, &block) }

    before(:example) do
      allow(session_stub_template).to receive(:build_stub).and_return(stub_builder)
      allow(session).to receive(:add_stub!)
    end

    it "builds a stub using any provided response overrides and block" do
      expect(session_stub_template).to receive(:build_stub).with(response_overrides).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

    it "adds a stub to the session with the provided name and created stub builder" do
      expect(session).to receive(:add_stub!).with(stub_builder)

      subject
    end

  end

end
