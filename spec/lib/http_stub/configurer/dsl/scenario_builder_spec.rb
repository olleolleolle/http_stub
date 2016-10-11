describe HttpStub::Configurer::DSL::ScenarioBuilder do

  let(:stub_fixture) { HttpStub::StubFixture.new }

  let(:scenario_name)        { "some scenario name" }
  let(:default_stub_template) { instance_double(HttpStub::Configurer::DSL::StubBuilderTemplate) }

  let(:scenario_builder) { HttpStub::Configurer::DSL::ScenarioBuilder.new(scenario_name, default_stub_template) }

  describe "#build_stub" do

    let(:response_overrides) { { status: 201 } }
    let(:block_verifier)     { double("BlockVerifier") }
    let(:block)              { lambda { block_verifier.verify } }

    subject { scenario_builder.build_stub(response_overrides, &block) }

    it "delegates to the provided default stub template" do
      expect(default_stub_template).to receive(:build_stub).with(response_overrides).and_yield
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

    let(:stub_builder) { instance_double(HttpStub::Configurer::DSL::StubBuilder) }

    context "when a block is provided" do

      let(:block_verifier) { double("BlockVerifier") }
      let(:block)          { lambda { block_verifier.verify } }

      subject { scenario_builder.add_stub!(&block) }

      before(:example) { allow(scenario_builder).to receive(:build_stub).and_return(stub_builder) }

      it "builds a stub whose values are initialized via the provided block" do
        expect(scenario_builder).to receive(:build_stub).with(no_args).and_yield
        expect(block_verifier).to receive(:verify)

        subject
      end

      it "results in the stub being built when the scenario is built" do
        subject
        expect(stub_builder).to receive(:build)

        scenario_builder.build
      end

    end

    context "when a builder is provided" do

      subject { scenario_builder.add_stub!(stub_builder) }

      it "results in the stub being built when the scenario is built" do
        subject
        expect(stub_builder).to receive(:build)

        scenario_builder.build
      end

    end

  end

  describe "#add_stubs!" do

    let(:stub_builders) { (1..3).map { instance_double(HttpStub::Configurer::DSL::StubBuilder) } }

    subject { scenario_builder.add_stubs!(stub_builders) }

    it "adds each stub to the scenario builders" do
      stub_builders.each { |stub_builder| expect(scenario_builder).to receive(:add_stub!).with(stub_builder) }

      subject
    end

  end

  describe "#build" do

    let(:scenario) { instance_double(HttpStub::Configurer::Request::Scenario) }

    subject { scenario_builder.build }

    before(:example) { allow(HttpStub::Configurer::Request::Scenario).to receive(:new).and_return(scenario) }

    it "creates a scenario that includes the name" do
      expect(HttpStub::Configurer::Request::Scenario).to receive(:new).with(hash_including(name: scenario_name))

      subject
    end

    context "when the scenario registers multiple stubs" do

      let(:stubs)         { (1..3).map { instance_double(HttpStub::Configurer::Request::Stub) } }
      let(:stub_builders) do
        stubs.map { |stub| instance_double(HttpStub::Configurer::DSL::StubBuilder, build: stub) }
      end

      before(:example) { scenario_builder.add_stubs!(stub_builders) }

      it "builds the stubs" do
        stub_builders.each { |stub_builder| expect(stub_builder).to receive(:build) }

        subject
      end

      it "creates a scenario that includes the built stubs" do
        expect(HttpStub::Configurer::Request::Scenario).to receive(:new).with(hash_including(stubs: stubs))

        subject
      end

    end

    context "when the scenario registers no stubs" do

      it "creates a scenario that has empty stubs" do
        expect(HttpStub::Configurer::Request::Scenario).to receive(:new).with(hash_including(stubs: []))

        subject
      end

    end

    context "when the scenario activates an array scenarios" do

      let(:triggered_scenario_names) { (1..3).map { |i| "scenario #{i}" } }

      before(:example) { scenario_builder.activate!(triggered_scenario_names) }

      it "creates a scenario that includes the triggered scenario names" do
        expect(HttpStub::Configurer::Request::Scenario).to(
          receive(:new).with(hash_including(triggered_scenario_names: triggered_scenario_names))
        )

        subject
      end

    end

    context "when the scenario activates a list of scenarios" do

      let(:triggered_scenario_names) { (1..3).map { |i| "activator_#{i}" } }

      before(:example) { scenario_builder.activate!(*triggered_scenario_names) }

      it "creates a scenario that includes the triggered scenario names" do
        expect(HttpStub::Configurer::Request::Scenario).to(
          receive(:new).with(hash_including(triggered_scenario_names: triggered_scenario_names))
        )

        subject
      end

    end

    context "when the scenario activates one scenario" do

      let(:triggered_scenario_name) { "a scenario" }

      before(:example) { scenario_builder.activate!(triggered_scenario_name) }

      it "creates a scenario that includes the triggered scenario names" do
        expect(HttpStub::Configurer::Request::Scenario).to(
          receive(:new).with(hash_including(triggered_scenario_names: [ triggered_scenario_name ]))
        )

        subject
      end

    end

    context "when the scenario does not activate any scenarios" do

      it "creates a scenario that has empty triggered scenario names" do
        expect(HttpStub::Configurer::Request::Scenario).to(
          receive(:new).with(hash_including(triggered_scenario_names: []))
        )

        subject
      end

    end

  end

end
