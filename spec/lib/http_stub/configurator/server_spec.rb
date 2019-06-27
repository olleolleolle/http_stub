describe HttpStub::Configurator::Server do

  let(:state)                { instance_double(HttpStub::Configurator::State) }
  let(:server_stub_template) { instance_double(HttpStub::Configurator::Stub::Template) }

  let(:block_verifier)  { double("BlockVerifier") }

  let(:server) { described_class.new(state) }

  before(:example) { allow(HttpStub::Configurator::Stub::Template).to receive(:new).and_return(server_stub_template) }

  it "creates a stub template to hold the default stub settings for the server" do
    expect(HttpStub::Configurator::Stub::Template).to receive(:new).with(no_args)

    server
  end

  shared_context "a server with a port configured" do

    before(:example) { server.port =  8888 }

  end

  describe "#port=" do

    let(:port) { "8888" }

    subject { server.port = port }

    it "delegates to the servers state" do
      allow(state).to receive(:port=).with(port)

      subject
    end

  end

  describe "#external_base_uri" do

    let(:external_base_uri) { "http://some/external/base/uri" }

    subject { server.external_base_uri }

    it "delegates to the servers state" do
      allow(state).to receive(:external_base_uri).and_return(external_base_uri)

      expect(subject).to eql(external_base_uri)
    end

  end

  describe "#session_identifer=" do

    let(:session_identifier) { { headers: :some_session_identifier } }

    subject { server.session_identifier = session_identifier }

    it "delegates to the servers state" do
      expect(state).to receive(:session_identifier=).with(session_identifier)

      subject
    end

  end

  describe "#enable" do

    let(:feature) { :a_feature }

    subject { server.enable(feature) }

    it "delegates to the servers state" do
      expect(state).to receive(:enable).with(feature)

      subject
    end

  end

  describe "#request_defaults=" do

    let(:args) { { request_rule_key: "request rule value" } }

    subject { server.request_defaults = args }

    it "establishes request matching rules on the default stub template" do
      expect(server_stub_template).to receive(:match_requests).with(args)

      subject
    end

  end

  describe "#response_defaults=" do

    let(:args) { { response_key: "response value" } }

    subject { server.response_defaults = args }

    it "establishes response values on the default stub template" do
      expect(server_stub_template).to receive(:respond_with).with(args)

      subject
    end

  end

  describe "#endpoint_template" do

    let(:block)             { lambda { block_verifier.verify } }
    let(:endpoint_template) { instance_double(HttpStub::Configurator::EndpointTemplate) }

    subject { server.endpoint_template(&block) }

    before(:example) { allow(HttpStub::Configurator::EndpointTemplate).to receive(:new).and_return(endpoint_template) }

    it "creates an endpoint template for the server" do
      expect(HttpStub::Configurator::EndpointTemplate).to receive(:new).with(server, anything)

      subject
    end

    it "creates an endpoint template extending the servers stub template" do
      expect(HttpStub::Configurator::EndpointTemplate).to receive(:new).with(anything, server_stub_template)

      subject
    end

    it "creates an endpoint template using any provided block to initialize the template" do
      allow(HttpStub::Configurator::EndpointTemplate).to receive(:new).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

    it "returns the created endpoint template" do
      expect(subject).to eql(endpoint_template)
    end

  end

  describe "#add_scenario!" do

    let(:scenario_name)    { "some/scenario/name" }
    let(:block)            { lambda { |_scenario| "some block" } }

    let(:scenario) { instance_double(HttpStub::Configurator::Scenario) }

    subject { server.add_scenario!(scenario_name, &block) }

    before(:example) do
      allow(HttpStub::Configurator::Scenario).to receive(:new).and_return(scenario)
      allow(state).to receive(:add_scenario)
    end

    it "creates a scenario containing the provided scenario name" do
      expect(HttpStub::Configurator::Scenario).to receive(:new).with(scenario_name, anything)

      subject
    end

    it "creates a scenario extending the servers stub template" do
      expect(HttpStub::Configurator::Scenario).to receive(:new).with(anything, server_stub_template)

      subject
    end

    it "yields the created scenario to the provided block" do
      expect { |block| server.add_scenario!(scenario_name, &block) }.to yield_with_args(scenario)
    end

    it "adds the scenario to submit the configurators state" do
      expect(state).to receive(:add_scenario).with(scenario)

      subject
    end

  end

  describe "#add_scenario_with_one_stub!" do

    let(:scenario_name) { "Some scenario name" }
    let(:block)         { lambda { block_verifier.verify } }

    let(:scenario) { instance_double(HttpStub::Configurator::Scenario, add_stub!: nil) }
    let(:the_stub) { instance_double(HttpStub::Configurator::Stub::Stub, invoke: nil) }

    subject { server.add_scenario_with_one_stub!(scenario_name, the_stub) }

    before(:each) { allow(server).to receive(:add_scenario!).and_yield(scenario) }

    it "adds a scenario with the provided name" do
      expect(server).to receive(:add_scenario!).with(scenario_name)

      subject
    end

    context "when a stub is provided" do

      subject { server.add_scenario_with_one_stub!(scenario_name, the_stub) }

      it "adds the stub to the scenario" do
        expect(scenario).to receive(:add_stub!).with(the_stub)

        subject
      end

    end

    context "when a block is provided" do

      subject { server.add_scenario_with_one_stub!(scenario_name, &block) }

      before(:example) do
        allow(scenario).to receive(:build_stub).and_return(the_stub)
        allow(scenario).to receive(:add_stub!)
      end

      it "builds a stub from the scenario" do
        expect(scenario).to receive(:build_stub).with(no_args)
        
        subject
      end

      it "adds the built stub to the scenario" do
        expect(scenario).to receive(:add_stub!).with(the_stub)

        subject
      end

      context "that accepts the stub as an argument" do

        let(:block) { lambda { |_stub| block_verifier.verify } }

        it "invokes the stub with no additional argument" do
          expect(the_stub).to receive(:invoke).with(nil).and_yield(the_stub)
          expect(block_verifier).to receive(:verify)

          subject
        end

      end

      context "that accepts the stub and scenario as arguments" do

        let(:block) { lambda { |_stub, _scenario| block_verifier.verify } }

        it "invokes the stub and supplies the scenario" do
          expect(the_stub).to receive(:invoke).with(scenario).and_yield(the_stub, scenario)
          expect(block_verifier).to receive(:verify)

          subject
        end

      end

    end

    context "when a stub and block is provided" do

      subject { server.add_scenario_with_one_stub!(scenario_name, the_stub, &block) }

      before(:example) { allow(scenario).to receive(:add_stub!) }

      it "adds the stub to the scenario" do
        expect(scenario).to receive(:add_stub!).with(the_stub)

        subject
      end

      context "and the block accepts the stub as an argument" do

        let(:block) { lambda { |_stub| block_verifier.verify } }

        it "invokes the stub with no additional argument" do
          expect(the_stub).to receive(:invoke).with(nil).and_yield(the_stub)
          expect(block_verifier).to receive(:verify)

          subject
        end

      end

      context "and the block accepts the stub and scenario as arguments" do

        let(:block) { lambda { |_stub, _scenario| block_verifier.verify } }

        it "invokes the stub and supplies the scenario" do
          expect(the_stub).to receive(:invoke).with(scenario).and_yield(the_stub, scenario)
          expect(block_verifier).to receive(:verify)

          subject
        end

      end

    end

  end

  describe "#build_stub" do

    let(:block) { lambda { block_verifier.verify } }

    subject { server.build_stub(&block) }

    it "delegates to the servers stub template" do
      expect(server_stub_template).to receive(:build_stub)

      subject
    end

    it "initializes the built stub using the provided block" do
      allow(server_stub_template).to receive(:build_stub).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

    it "returns the built stub" do
      built_stub = instance_double(HttpStub::Configurator::Stub::Stub)
      allow(server_stub_template).to receive(:build_stub).and_return(built_stub)

      expect(subject).to eql(built_stub)
    end

  end

  describe "#add_stub!" do

    let(:the_stub) { instance_double(HttpStub::Configurator::Stub::Stub) }

    context "when a stub is provided" do

      subject { server.add_stub!(the_stub) }

      it "adds the stub to the configurators state" do
        expect(state).to receive(:add_stub).with(the_stub)

        subject
      end

    end

    context "when a block is provided" do

      let(:block) { lambda { block_verifier.verify } }

      subject { server.add_stub!(&block) }

      before(:each) do
        allow(server_stub_template).to receive(:build_stub).and_return(the_stub)
        allow(state).to receive(:add_stub)
      end

      it "builds a stub via the servers stub template" do
        expect(server_stub_template).to receive(:build_stub)

        subject
      end

      it "invokes the block with the created stub" do
        allow(server_stub_template).to receive(:build_stub).and_yield
        expect(block_verifier).to receive(:verify)

        subject
      end

      it "adds the stub to the configurators state" do
        expect(state).to receive(:add_stub).with(the_stub)

        subject
      end

    end

  end

  describe "#add_stubs!" do

    let(:the_stubs) { (1..3).map { instance_double(HttpStub::Configurator::Stub::Stub) } }

    subject { server.add_stubs!(the_stubs) }

    it "add the stubs to the configurators state" do
      the_stubs.each { |the_stub| expect(state).to receive(:add_stub).with(the_stub) }

      subject
    end

  end

end
