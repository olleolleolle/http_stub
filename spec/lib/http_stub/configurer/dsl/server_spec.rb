describe HttpStub::Configurer::DSL::Server do

  let(:configuration)         { instance_double(HttpStub::Configurer::Server::Configuration) }
  let(:server_facade)         { instance_double(HttpStub::Configurer::Server::Facade) }
  let(:default_stub_template) { instance_double(HttpStub::Configurer::DSL::StubBuilderTemplate) }
  let(:memory_session)        { instance_double(HttpStub::Configurer::DSL::Session) }
  let(:transactional_session) { instance_double(HttpStub::Configurer::DSL::Session) }
  let(:session_factory)       do
    instance_double(HttpStub::Configurer::DSL::SessionFactory, memory:        memory_session,
                                                               transactional: transactional_session)
  end

  let(:default_session) { memory_session }
  let(:block_verifier)  { double("BlockVerifier") }

  let(:server) { described_class.new }

  before(:example) do
    allow(HttpStub::Configurer::Server::Configuration).to receive(:new).and_return(configuration)
    allow(HttpStub::Configurer::Server::Facade).to receive(:new).and_return(server_facade)
    allow(HttpStub::Configurer::DSL::StubBuilderTemplate).to receive(:new).and_return(default_stub_template)
    allow(HttpStub::Configurer::DSL::SessionFactory).to receive(:new).and_return(session_factory)
  end

  it "creates a server configuration" do
    expect(HttpStub::Configurer::Server::Configuration).to receive(:new)

    server
  end

  it "creates a facade to interact with the stub server based on the configuration" do
    expect(HttpStub::Configurer::Server::Facade).to receive(:new).with(configuration)

    server
  end

  it "creates a stub builder template to hold the default stub settings for the server" do
    expect(HttpStub::Configurer::DSL::StubBuilderTemplate).to receive(:new).with(no_args)

    server
  end

  it "creates a session factory that creates sessions interacting with the servers facade and stub template" do
    expect(HttpStub::Configurer::DSL::SessionFactory).to receive(:new).with(server_facade, default_stub_template)

    server
  end

  shared_context "a server with host and port configured" do

    before(:example) do
      server.host = "some_host"
      server.port =  8888
    end

  end

  describe "#host" do

    let(:host) { "some_host" }

    subject { server.host }

    it "delegates to the servers configuration" do
      allow(configuration).to receive(:host).and_return(host)

      expect(subject).to eql(host)
    end

  end

  describe "#host=" do

    let(:host) { "some_host" }

    subject { server.host = host }

    it "delegates to the servers configuration" do
      allow(configuration).to receive(:host=).with(host)

      subject
    end

  end

  describe "#port" do

    let(:port) { "8888" }

    subject { server.port }

    it "delegates to the servers configuration" do
      allow(configuration).to receive(:port).and_return(port)

      expect(subject).to eql(port)
    end

  end

  describe "#port=" do

    let(:port) { "8888" }

    subject { server.port = port }

    it "delegates to the servers configuration" do
      allow(configuration).to receive(:port=).with(port)

      subject
    end

  end

  describe "#base_uri" do

    let(:base_uri) { "some_host:8888" }

    subject { server.base_uri }

    it "delegates to the servers configuration" do
      allow(configuration).to receive(:base_uri).and_return(base_uri)

      expect(subject).to eql(base_uri)
    end

  end

  describe "#external_base_uri" do

    let(:external_base_uri) { "http://some/external/base/uri" }

    subject { server.external_base_uri }

    it "delegates to the servers configuration" do
      allow(configuration).to receive(:external_base_uri).and_return(external_base_uri)

      expect(subject).to eql(external_base_uri)
    end

  end

  describe "#session_identifier" do

    let(:session_identifier) { { headers: :some_session_identifier } }

    subject { server.session_identifier }

    it "delegates to the servers configuration" do
      allow(configuration).to receive(:session_identifier).and_return(session_identifier)

      expect(subject).to eql(session_identifier)
    end

  end

  describe "#session_identifer=" do

    let(:session_identifier) { { headers: :some_session_identifier } }

    subject { server.session_identifier = session_identifier }

    it "delegates to the servers configuration" do
      expect(configuration).to receive(:session_identifier=).with(session_identifier)

      subject
    end

  end

  describe "#enable" do

    let(:features) { (1..3).map { |i| "feature_#{i}".to_sym } }

    subject { server.enable(*features) }

    it "delegates to the sessions configuration" do
      expect(configuration).to receive(:enable).with(*features)

      subject
    end

  end

  describe "#enabled?" do

    let(:feature) { :some_feature }

    subject { server.enabled?(feature) }

    it "delegates to the servers configuration" do
      expect(configuration).to receive(:enabled?).and_return(true)

      expect(subject).to be(true)
    end

  end

  describe "#request_defaults=" do

    let(:args) { { request_rule_key: "request rule value" } }

    subject { server.request_defaults = args }

    it "establishes request matching rules on the default stub template" do
      expect(default_stub_template).to receive(:match_requests).with(args)

      subject
    end

  end

  describe "#response_defaults=" do

    let(:args) { { response_key: "response value" } }

    subject { server.response_defaults = args }

    it "establishes response values on the default stub template" do
      expect(default_stub_template).to receive(:respond_with).with(args)

      subject
    end

  end

  it "causes session operations to be performed against the memory session prior to initialization" do
    expect(memory_session).to receive(:activate!)

    server.activate!("some scenario name")
  end

  describe "#initialize!" do

    subject { server.initialize! }

    before(:example) { allow(server_facade).to receive(:initialize_server) }

    it "initializes the server via the facade" do
      expect(server_facade).to receive(:initialize_server)

      subject
    end

    it "causes subsequent session operations to be performed against the transactional session" do
      subject
      expect(transactional_session).to receive(:activate!)

      server.activate!("some scenario name")
    end

  end

  describe "#has_started!" do

    subject { server.has_started! }

    before(:example) { allow(server_facade).to receive(:server_has_started) }

    it "informs the facade that the server has started" do
      expect(server_facade).to receive(:server_has_started)

      subject
    end

    it "causes subsequent session operations to be performed against the transactional session" do
      subject
      expect(transactional_session).to receive(:activate!)

      server.activate!("some scenario name")
    end

  end

  describe "#reset!" do

    subject { server.reset! }

    it "delegates to the server facade" do
      expect(server_facade).to receive(:reset)

      subject
    end

  end

  describe "#add_scenario!" do

    let(:scenario_name)    { "some/scenario/name" }
    let(:block)            { lambda { |_scenario| "some block" } }

    let(:scenario)         { instance_double(HttpStub::Configurer::Request::Scenario) }
    let(:scenario_builder) { instance_double(HttpStub::Configurer::DSL::ScenarioBuilder, build: scenario) }

    subject { server.add_scenario!(scenario_name, &block) }

    before(:example) do
      allow(HttpStub::Configurer::DSL::ScenarioBuilder).to receive(:new).and_return(scenario_builder)
      allow(server_facade).to receive(:define_scenario)
    end

    it "creates a scenario builder containing the provided scenario name" do
      expect(HttpStub::Configurer::DSL::ScenarioBuilder).to receive(:new).with(scenario_name, anything)

      subject
    end

    it "creates a scenario builder extending the servers default stub template" do
      expect(HttpStub::Configurer::DSL::ScenarioBuilder).to receive(:new).with(anything, default_stub_template)

      subject
    end

    it "yields the created builder to the provided block" do
      expect { |block| server.add_scenario!(scenario_name, &block) }.to yield_with_args(scenario_builder)
    end

    it "builds the scenario request" do
      expect(scenario_builder).to receive(:build).and_return(scenario)

      subject
    end

    it "informs the server facade to submit the scenario request" do
      expect(server_facade).to receive(:define_scenario).with(scenario)

      subject
    end

  end

  describe "#add_scenario_with_one_stub!" do

    let(:scenario_name) { "Some scenario name" }
    let(:block)         { lambda { block_verifier.verify } }

    let(:scenario_builder) { instance_double(HttpStub::Configurer::DSL::ScenarioBuilder, add_stub!: nil) }
    let(:stub_builder)     { instance_double(HttpStub::Configurer::DSL::StubBuilder, invoke: nil) }

    subject { server.add_scenario_with_one_stub!(scenario_name, stub_builder) }

    before(:each) { allow(server).to receive(:add_scenario!).and_yield(scenario_builder) }

    it "adds a scenario with the provided name" do
      expect(server).to receive(:add_scenario!).with(scenario_name)

      subject
    end

    it "adds a stub to the scenario" do
      expect(scenario_builder).to receive(:add_stub!)

      subject
    end

    context "when a builder is provided" do

      subject { server.add_scenario_with_one_stub!(scenario_name, stub_builder) }

      it "adds a stub to the scenario with the provided builder" do
        expect(scenario_builder).to receive(:add_stub!).with(stub_builder)

        subject
      end

    end

    context "when a block is provided" do

      let(:block) { lambda { block_verifier.verify } }

      subject { server.add_scenario_with_one_stub!(scenario_name, &block) }

      before(:example) { allow(scenario_builder).to receive(:add_stub!).and_yield(stub_builder) }

      it "requests the stub builder invoke the provided block" do
        expect(stub_builder).to receive(:invoke).and_yield
        expect(block_verifier).to receive(:verify)

        subject
      end

    end

  end

  describe "#endpoint_template" do

    let(:block)                    { lambda { block_verifier.verify } }
    let(:server_endpoint_template) { instance_double(HttpStub::Configurer::DSL::ServerEndpointTemplate) }

    subject { server.endpoint_template(&block) }

    before(:example) do
      allow(HttpStub::Configurer::DSL::ServerEndpointTemplate).to receive(:new).and_return(server_endpoint_template)
    end

    it "creates an endpoint template for the server" do
      expect(HttpStub::Configurer::DSL::ServerEndpointTemplate).to receive(:new).with(server, anything)

      subject
    end

    it "creates an endpoint template using the curently default session" do
      expect(HttpStub::Configurer::DSL::ServerEndpointTemplate).to receive(:new).with(anything, default_session)

      subject
    end

    it "creates an endpoint template using any provided block to initialize the template" do
      allow(HttpStub::Configurer::DSL::ServerEndpointTemplate).to receive(:new).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

    it "returns the created endpoint template" do
      expect(subject).to eql(server_endpoint_template)
    end

  end

  describe "#session" do

    let(:session_id) { "some session id" }

    let(:session) { instance_double(HttpStub::Configurer::DSL::Session) }

    subject { server.session(session_id) }

    before(:example) { allow(session_factory).to receive(:create).and_return(session) }

    it "creates a DSL for interacting with a session for the provided ID via the session factory" do
      expect(session_factory).to receive(:create).with(session_id)

      subject
    end

    it "returns the created session" do
      expect(subject).to eql(session)
    end

  end

  describe "#activate!" do

    let(:scenario_name) { "Some scenario name" }

    subject { server.activate!(scenario_name) }

    it "delegates to the default session" do
      expect(default_session).to receive(:activate!).with(scenario_name)

      subject
    end

  end

  describe "#clear_sessions!" do

    subject { server.clear_sessions! }

    it "delegates to the server facade" do
      expect(server_facade).to receive(:clear_sessions)

      subject
    end

  end

  describe "#build_stub" do

    let(:block) { lambda { block_verifier.verify } }

    subject { server.build_stub(&block) }

    it "delegates to the default session" do
      expect(default_session).to receive(:build_stub)

      subject
    end

    it "initializes the built stub using the provided block" do
      allow(default_session).to receive(:build_stub).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

    it "returns the built stub" do
      built_stub = instance_double(HttpStub::Configurer::DSL::StubBuilder)
      allow(default_session).to receive(:build_stub).and_return(built_stub)

      expect(subject).to eql(built_stub)
    end

  end

  describe "#add_stub!" do

    context "when a stub builder is provided" do

      let(:stub_builder) { instance_double(HttpStub::Configurer::DSL::StubBuilder) }

      subject { server.add_stub!(stub_builder) }

      it "delegates to the default session" do
        expect(default_session).to receive(:add_stub!).with(stub_builder)

        subject
      end

    end

    context "when a block is provided" do

      let(:block) { lambda { block_verifier.verify } }

      subject { server.add_stub!(&block) }

      it "delegates to the default session" do
        expect(default_session).to receive(:add_stub!)

        subject
      end

      it "supplies the provided block to the session" do
        allow(default_session).to receive(:add_stub!).and_yield
        expect(block_verifier).to receive(:verify)

        subject
      end

    end

  end

  describe "#add_stubs!" do

    let(:stub_builders) { (1..3).map { instance_double(HttpStub::Configurer::DSL::StubBuilder) } }

    subject { server.add_stubs!(stub_builders) }

    it "delegates to the default session" do
      expect(default_session).to receive(:add_stubs!).with(stub_builders)

      subject
    end

  end

  describe "#recall_stubs!" do

    subject { server.recall_stubs! }

    it "resets the default session" do
      expect(default_session).to receive(:reset!)

      subject
    end

  end

  describe "#clear_stubs!" do

    subject { server.clear_stubs! }

    it "delegates to the default session" do
      expect(default_session).to receive(:clear!)

      subject
    end

  end

end
