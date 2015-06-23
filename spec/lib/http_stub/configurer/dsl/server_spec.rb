describe HttpStub::Configurer::DSL::Server do

  let(:server_facade) { instance_double(HttpStub::Configurer::Server::Facade) }

  let(:server) { HttpStub::Configurer::DSL::Server.new(server_facade) }

  shared_context "establish response defaults" do

    let(:response_defaults) { { key: "value" } }

    before(:example) { server.response_defaults = { key: "value" } }

  end

  it "produces stub builders" do
    expect(server).to be_a(HttpStub::Configurer::DSL::StubBuilderProducer)
  end

  describe "#base_uri" do

    subject { server.base_uri }

    before(:example) do
      server.host = "some_host"
      server.port =  8888
    end

    it "returns a uri that combines any established host and port" do
      expect(subject).to include("some_host:8888")
    end

    it "returns a uri accessed via http" do
      expect(subject).to match(/^http:\/\//)
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

    context "when response defaults have been established" do

      include_context "establish response defaults"

      it "creates a scenario builder containing the response defaults" do
        expect(HttpStub::Configurer::DSL::ScenarioBuilder).to receive(:new).with(response_defaults, anything)

        subject
      end

      it "creates a scenario builder containing the provided scenario name" do
        expect(HttpStub::Configurer::DSL::ScenarioBuilder).to receive(:new).with(anything, scenario_name)

        subject
      end

    end

    context "when no response defaults have been established" do

      it "creates a scenario builder with empty response defaults" do
        expect(HttpStub::Configurer::DSL::ScenarioBuilder).to receive(:new).with({}, anything)

        subject
      end

    end

    it "yields the created builder to the provided block" do
      expect(block).to receive(:call).with(scenario_builder)

      subject
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

  describe "#add_one_stub_scenario!" do

    let(:scenario_name)  { "some_scenario_name" }
    let(:block_verifier) { double("BlockVerifier") }
    let(:block)          { lambda { block_verifier.verify } }

    let(:scenario_builder) { instance_double(HttpStub::Configurer::DSL::ScenarioBuilder) }
    let(:stub_builder)     { instance_double(HttpStub::Configurer::DSL::StubBuilder, invoke: nil) }

    subject { server.add_one_stub_scenario!(scenario_name, &block) }

    before(:each) do
      allow(server).to receive(:add_scenario!).and_yield(scenario_builder)
      allow(scenario_builder).to receive(:add_stub!).and_yield(stub_builder)
    end

    it "adds a scenario with the provided name" do
      expect(server).to receive(:add_scenario!).with(scenario_name)

      subject
    end

    it "adds a stub to the scenario" do
      expect(scenario_builder).to receive(:add_stub!)

      subject
    end

    it "requests the stub builder invoke the provided block" do
      expect(stub_builder).to receive(:invoke).and_yield
      expect(block_verifier).to receive(:verify)

      subject
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

    it "returns the created endpoint template" do
      expect(subject).to eql(endpoint_template)
    end

    it "creates a template for the server" do
      expect(HttpStub::Configurer::DSL::EndpointTemplate).to(
        receive(:new).with(server, anything).and_return(endpoint_template)
      )

      subject
    end

    context "when response defaults have been established" do

      include_context "establish response defaults"

      it "creates a template with the defaults" do
        expect(HttpStub::Configurer::DSL::EndpointTemplate).to(
          receive(:new).with(anything, response_defaults).and_return(endpoint_template)
        )

        subject
      end

    end

    context "when no response defaults have been established" do

      it "creates a template with empty response defaults" do
        expect(HttpStub::Configurer::DSL::EndpointTemplate).to(
          receive(:new).with(anything, {}).and_return(endpoint_template)
        )

        subject
      end

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

    context "when response defaults have been established" do

      let(:response_defaults) { { key: "value" } }

      before(:example) { server.response_defaults = { key: "value" } }

      it "creates a stub activator builder containing the response defaults" do
        expect(HttpStub::Configurer::DSL::StubActivatorBuilder).to receive(:new).with(response_defaults)

        subject
      end

    end

    context "when no response defaults have been established" do

      it "creates a stub activator builder with empty response defaults" do
        expect(HttpStub::Configurer::DSL::StubActivatorBuilder).to receive(:new).with({})

        subject
      end

    end

    it "yields the created builder to the provided block" do
      expect(block).to receive(:call).with(stub_activator_builder)

      subject
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
