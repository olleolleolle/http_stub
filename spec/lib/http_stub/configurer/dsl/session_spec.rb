describe HttpStub::Configurer::DSL::Session do

  let(:id)                    { "some_session_id" }
  let(:session_facade)        { instance_double(HttpStub::Configurer::Server::SessionFacade) }
  let(:server_facade)         do
    instance_double(HttpStub::Configurer::Server::Facade, create_session_facade: session_facade)
  end
  let(:default_stub_template) { instance_double(HttpStub::Configurer::DSL::StubBuilderTemplate) }

  let(:block_verifier) { double("BlockVerifier") }

  let(:session) { described_class.new(id, server_facade, default_stub_template) }

  it "creates a facade the session uses to interact with the stub server" do
    expect(server_facade).to receive(:create_session_facade).with(id)

    session
  end

  describe "#mark_as_default!" do

    subject { session.mark_as_default! }

    it "marks the session as the servers default via the session facade" do
      expect(session_facade).to receive(:mark_as_default)

      subject
    end

  end

  describe "#endpoint_template" do

    let(:block)                    { lambda { block_verifier.verify } }
    let(:session_endpoint_template) { instance_double(HttpStub::Configurer::DSL::SessionEndpointTemplate) }

    subject { session.endpoint_template(&block) }

    before(:example) do
      allow(HttpStub::Configurer::DSL::SessionEndpointTemplate).to receive(:new).and_return(session_endpoint_template)
    end

    it "creates an endpoint template for the session" do
      expect(HttpStub::Configurer::DSL::SessionEndpointTemplate).to receive(:new).with(session, anything)

      subject
    end

    it "creates an endpoint template that extends the default stub template" do
      expect(HttpStub::Configurer::DSL::SessionEndpointTemplate).to receive(:new).with(anything, default_stub_template)

      subject
    end

    it "creates an endpoint template using any provided block to initialize the template" do
      allow(HttpStub::Configurer::DSL::SessionEndpointTemplate).to receive(:new).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

    it "returns the created endpoint template" do
      expect(subject).to eql(session_endpoint_template)
    end

  end

  describe "#activate!" do

    let(:scenario_names) { (1..3).map { |i| "Scenario name #{i}" } }

    subject { session.activate!(*scenario_names) }

    it "delegates to the session facade in order to activate the scenarios" do
      expect(session_facade).to receive(:activate).with(scenario_names)

      subject
    end

  end

  describe "#build_stub" do

    let(:block) { lambda { block_verifier.verify } }

    subject { session.build_stub(&block) }

    it "delegates to the servers default stub template" do
      expect(default_stub_template).to receive(:build_stub)

      subject
    end

    it "initializes the built stub using the provided block" do
      allow(default_stub_template).to receive(:build_stub).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

    it "returns the built stub" do
      built_stub = instance_double(HttpStub::Configurer::DSL::StubBuilder)
      allow(default_stub_template).to receive(:build_stub).and_return(built_stub)

      expect(subject).to eql(built_stub)
    end

  end

  describe "#add_stub!" do

    let(:built_stub)   { instance_double(HttpStub::Configurer::Request::Stub) }
    let(:stub_builder) { instance_double(HttpStub::Configurer::DSL::StubBuilder, build: built_stub) }

    before(:example) { allow(session_facade).to receive(:stub_response) }

    context "when a stub builder is provided" do

      subject { session.add_stub!(stub_builder) }

      it "builds a stub from the provided builder" do
        expect(stub_builder).to receive(:build)

        subject
      end

      it "registers the built stub via the session facade" do
        expect(session_facade).to receive(:stub_response).with(built_stub)

        subject
      end

    end

    context "when a block is provided" do

      let(:block) { lambda { block_verifier.verify } }

      subject { session.add_stub!(&block) }

      before(:example) { allow(default_stub_template).to receive(:build_stub).and_return(stub_builder) }

      it "creates a stub builder via the servers default stub template" do
        expect(default_stub_template).to receive(:build_stub)

        subject
      end

      it "supplies the provided block when creating the stub builder" do
        allow(default_stub_template).to receive(:build_stub).and_return(stub_builder).and_yield
        expect(block_verifier).to receive(:verify)

        subject
      end

      it "builds a stub from the created builder" do
        expect(stub_builder).to receive(:build)

        subject
      end

      it "registers the built stub via the session facade" do
        expect(session_facade).to receive(:stub_response).with(built_stub)

        subject
      end

    end

  end

  describe "#add_stubs!" do

    let(:stub_builders) { (1..3).map { instance_double(HttpStub::Configurer::DSL::StubBuilder) } }

    subject { session.add_stubs!(stub_builders) }

    it "adds each provided stub" do
      stub_builders.each { |stub_builder| allow(session).to receive(:add_stub!).with(stub_builder) }

      subject
    end

  end

  describe "#reset!" do

    subject { session.reset! }

    it "resets the sessions stubs via the session facade" do
      expect(session_facade).to receive(:reset_stubs)

      subject
    end

  end

  describe "#clear!" do

    subject { session.clear! }

    it "clears the sessions stubs via the session facade" do
      expect(session_facade).to receive(:clear_stubs)

      subject
    end

  end

  describe "#delete!" do

    subject { session.delete! }

    it "deletes the session via the session facade" do
      expect(session_facade).to receive(:delete)

      subject
    end

  end

end
