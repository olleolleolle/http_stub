describe HttpStub::Configurer::DSL::Server do

  let(:server_facade)        { instance_double(HttpStub::Configurer::Server::Facade) }
  let(:default_stub_builder) { instance_double(HttpStub::Configurer::DSL::StubBuilder) }

  let(:server) { HttpStub::Configurer::DSL::Server.new(server_facade) }

  before(:example) do
    allow(HttpStub::Configurer::DSL::StubBuilder).to receive(:new).with(no_args).and_return(default_stub_builder)
  end

  shared_context "a server with host and port configured" do

    before(:example) do
      server.host = "some_host"
      server.port =  8888
    end

  end

  it "produces stub builders" do
    expect(server).to be_a(HttpStub::Configurer::DSL::StubBuilderProducer)
  end

  it "activates scenarios" do
    expect(server).to be_a(HttpStub::Configurer::DSL::ScenarioActivator)
  end

  describe "#base_uri" do

    subject { server.base_uri }

    include_context "a server with host and port configured"

    it "returns a uri that combines any established host and port" do
      expect(subject).to include("some_host:8888")
    end

    it "returns a uri accessed via http" do
      expect(subject).to match(/^http:\/\//)
    end

  end

  describe "#external_base_uri" do

    subject { server.external_base_uri }

    include_context "a server with host and port configured"

    context "when an external base URI environment variable is established" do

      let(:external_base_uri) { "http://some/external/base/uri" }

      before(:example) { ENV["STUB_EXTERNAL_BASE_URI"] = external_base_uri }
      after(:example)  { ENV["STUB_EXTERNAL_BASE_URI"] = nil }

      it "returns the environment variable" do
        expect(subject).to eql(external_base_uri)
      end

    end

    context "when an external base URI environment variable is not established" do

      it "returns the base URI" do
        expect(subject).to eql(server.base_uri)
      end

    end

    it "returns a uri that combines any established host and port" do
      expect(subject).to include("some_host:8888")
    end

    it "returns a uri accessed via http" do
      expect(subject).to match(/^http:\/\//)
    end

  end

  describe "#enable" do

    context "when a feature is provided" do

      let(:feature) { :some_feature }

      subject { server.enable(feature) }

      it "enables the feature" do
        subject

        expect(server.enabled?(feature)).to be(true)
      end

    end

    context "when features are provided" do

      let(:features) { (1..3).map { |i| "feature_#{i}".to_sym } }

      subject { server.enable(*features) }

      it "enables the features" do
        subject

        features.each { |feature| expect(server.enabled?(feature)).to be(true) }
      end

    end

  end

  describe "#enabled?" do

    let(:feature) { :some_feature }

    subject { server.enabled?(feature) }

    context "when a feature is enabled" do

      before(:example) { server.enable(feature) }

      it "returns false" do
        expect(subject).to be(true)
      end

    end

    context "when a feature is not enabled" do

      it "returns false" do
        expect(subject).to be(false)
      end

    end

  end

  describe "#request_defaults=" do

    let(:args) { { request_rule_key: "request rule value" } }

    it "establishes request matcher rules on the default stub builder" do
      expect(default_stub_builder).to receive(:match_requests).with(args)

      server.request_defaults = args
    end

  end

  describe "#response_defaults=" do

    let(:args) { { response_key: "response value" } }

    it "establishes response values on the default stub builder" do
      expect(default_stub_builder).to receive(:respond_with).with(args)

      server.response_defaults = args
    end

  end

  describe "#has_started!" do

    it "informs the facade that the server has started" do
      expect(server_facade).to receive(:server_has_started)

      server.has_started!
    end

  end

  describe "#add_stub!" do

    let(:stub)         { instance_double(HttpStub::Configurer::Request::Stub) }
    let(:stub_builder) { instance_double(HttpStub::Configurer::DSL::StubBuilder, build: stub) }

    before(:example) { allow(server_facade).to receive(:stub_response) }

    shared_examples_for "adding a stub request" do

      it "builds the stub request" do
        expect(stub_builder).to receive(:build).and_return(stub)

        subject
      end

      it "informs the server facade of the stub request" do
        expect(server_facade).to receive(:stub_response).with(stub)

        subject
      end

    end

    context "when a stub builder is provided" do

      subject { server.add_stub!(stub_builder) }

      it_behaves_like "adding a stub request"

    end

    context "when a stub builder is not provided" do

      let(:block_verifier) { double("BlockVerifier") }
      let(:block)          { lambda { block_verifier.verify } }

      before(:example) do
        allow(HttpStub::Configurer::DSL::StubBuilder).to receive(:new).and_return(stub_builder)
        allow(stub_builder).to receive(:invoke)
      end

      subject { server.add_stub!(&block) }

      it "creates a stub builder" do
        expect(HttpStub::Configurer::DSL::StubBuilder).to receive(:new)

        subject
      end

      it "requests the created builder invoke the provided block" do
        expect(stub_builder).to receive(:invoke).and_yield
        expect(block_verifier).to receive(:verify)

        subject
      end

      it_behaves_like "adding a stub request"

    end

  end

  describe "#add_scenario!" do

    let(:scenario_name)    { "some/scenario/name" }
    let(:scenario)         { instance_double(HttpStub::Configurer::Request::Scenario) }
    let(:scenario_builder) { instance_double(HttpStub::Configurer::DSL::ScenarioBuilder, build: scenario) }

    before(:example) { allow(server_facade).to receive(:define_scenario) }

    let(:block) { lambda { |_scenario| "some block" } }

    before(:example) do
      allow(HttpStub::Configurer::DSL::ScenarioBuilder).to receive(:new).and_return(scenario_builder)
    end

    subject { server.add_scenario!(scenario_name, &block) }

    it "creates a scenario builder containing the servers default stub builder" do
      expect(HttpStub::Configurer::DSL::ScenarioBuilder).to receive(:new).with(default_stub_builder, anything)

      subject
    end

    it "creates a scenario builder containing the provided scenario name" do
      expect(HttpStub::Configurer::DSL::ScenarioBuilder).to receive(:new).with(anything, scenario_name)

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

    let(:scenario_name)  { "Some scenario name" }
    let(:block_verifier) { double("BlockVerifier") }
    let(:block)          { lambda { block_verifier.verify } }

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

      let(:block_verifier) { double("BlockVerifier") }
      let(:block)          { lambda { block_verifier.verify } }

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

    let(:block_verifier)    { double("BlockVerifier") }
    let(:block)             { lambda { block_verifier.verify } }
    let(:endpoint_template) { instance_double(HttpStub::Configurer::DSL::EndpointTemplate, invoke: nil) }

    subject { server.endpoint_template(&block) }

    before(:example) do
      allow(HttpStub::Configurer::DSL::EndpointTemplate).to receive(:new).and_return(endpoint_template)
    end

    it "requests the endpoint template invoke the provided block" do
      expect(endpoint_template).to receive(:invoke).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

    it "creates a template for the server" do
      expect(HttpStub::Configurer::DSL::EndpointTemplate).to receive(:new).with(server).and_return(endpoint_template)

      subject
    end

    it "returns the created endpoint template" do
      expect(subject).to eql(endpoint_template)
    end

  end

  describe "#add_activator!" do

    let(:scenario) { instance_double(HttpStub::Configurer::Request::Scenario) }
    let(:stub_activator_builder) do
      instance_double(HttpStub::Configurer::DSL::StubActivatorBuilder, build: scenario)
    end

    before(:example) { allow(server_facade).to receive(:define_scenario) }

    let(:block) { lambda { |_activator| "some block" } }

    before(:example) do
      allow(HttpStub::Configurer::DSL::StubActivatorBuilder).to receive(:new).and_return(stub_activator_builder)
    end

    subject { server.add_activator!(&block) }

    it "creates a stub activator builder containing the servers default stub builder" do
      expect(HttpStub::Configurer::DSL::StubActivatorBuilder).to receive(:new).with(default_stub_builder)

      subject
    end

    it "yields the created builder to the provided block" do
      expect { |block| server.add_activator!(&block) }.to yield_with_args(stub_activator_builder)
    end

    it "builds a scenario request" do
      expect(stub_activator_builder).to receive(:build).and_return(scenario)

      subject
    end

    it "informs the server facade to submit the scenario request" do
      expect(server_facade).to receive(:define_scenario).with(scenario)

      subject
    end

  end

  describe "#activate!" do

    let(:scenario_name) { "/some/scenario/name" }

    it "delegates to the server facade" do
      expect(server_facade).to receive(:activate).with(scenario_name)

      server.activate!(scenario_name)
    end

  end

  describe "#remember_stubs" do

    it "delegates to the server facade" do
      expect(server_facade).to receive(:remember_stubs)

      server.remember_stubs
    end

  end

  describe "#recall_stubs!" do

    it "delegates to the server facade" do
      expect(server_facade).to receive(:recall_stubs)

      server.recall_stubs!
    end

  end

  describe "#clear_stubs!" do

    it "delegates to the server facade" do
      expect(server_facade).to receive(:clear_stubs)

      server.clear_stubs!
    end

  end

  describe "#clear_scenarios!" do

    it "delegates to the server facade" do
      expect(server_facade).to receive(:clear_scenarios)

      server.clear_scenarios!
    end

  end

end
