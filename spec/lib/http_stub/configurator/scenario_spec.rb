describe HttpStub::Configurator::Scenario do

  let(:name)                  { "some scenario name" }
  let(:default_stub_template) { instance_double(HttpStub::Configurator::Stub::Template) }

  let(:scenario) { HttpStub::Configurator::Scenario.new(name, default_stub_template) }

  describe "#build_stub" do

    let(:response_overrides) { { status: 201 } }
    let(:block_verifier)     { double("BlockVerifier") }
    let(:block)              { lambda { block_verifier.verify } }

    subject { scenario.build_stub(response_overrides, &block) }

    it "delegates to the provided default stub template" do
      expect(default_stub_template).to receive(:build_stub).with(response_overrides).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

    it "returns the built stub" do
      built_stub = instance_double(HttpStub::Configurator::Stub::Stub)
      allow(default_stub_template).to receive(:build_stub).and_return(built_stub)

      expect(subject).to eql(built_stub)
    end

  end

  describe "#add_stub!" do

    let(:stub_hash)  { { stub_key: "stub value" } }
    let(:built_stub) { instance_double(HttpStub::Configurator::Stub::Stub, to_hash: stub_hash) }

    context "when a block is provided" do

      let(:block_verifier) { double("BlockVerifier") }
      let(:block)          { lambda { block_verifier.verify } }

      subject { scenario.add_stub!(&block) }

      before(:example) { allow(default_stub_template).to receive(:build_stub).and_return(built_stub) }

      it "builds a stub whose values are initialized via the provided block" do
        expect(default_stub_template).to receive(:build_stub).with(no_args).and_yield.and_return(built_stub)
        expect(block_verifier).to receive(:verify)

        subject
      end

      it "adds the stub to the scenario" do
        subject

        expect(scenario.to_hash).to include(stubs: [ stub_hash ])
      end

    end

    context "when a stub is provided" do

      subject { scenario.add_stub!(built_stub) }

      it "adds the stub to the scenario" do
        subject

        expect(scenario.to_hash).to include(stubs: [ stub_hash ])
      end

    end

  end

  describe "#add_stubs!" do

    let(:stub_hashes) { (1..3).map { |i| { "stub_#{i}_key" => "stub value #{i}" } } }
    let(:stubs)       { stub_hashes.map { |hash| instance_double(HttpStub::Configurator::Stub::Stub, to_hash: hash) } }

    subject { scenario.add_stubs!(stubs) }

    it "adds each stub to the scenario" do
      subject

      expect(scenario.to_hash).to include(stubs: stub_hashes)
    end

  end

  describe "#activate_scenarios!" do

    let(:scenario_names) { (1..3).map { |i| "scenario name #{i}" } }

    context "when the scenario names are provided as an array" do

      subject { scenario.activate_scenarios!(scenario_names) }

      it "adds the scenario names to scenarios triggered by this scenario" do
        subject

        expect(scenario.to_hash).to include(triggered_scenario_names: scenario_names)
      end

    end

    context "when the scenario names are provided as a list of parameters" do

      subject { scenario.activate_scenarios!(*scenario_names) }

      it "adds the scenario names to scenarios triggered by this scenario" do
        subject

        expect(scenario.to_hash).to include(triggered_scenario_names: scenario_names)
      end

    end

  end

  describe "#activate!" do

    context "when the scenario is activated" do

      subject { scenario.activate! }

      it "marks the scenario as immediately active" do
        subject

        expect(scenario.to_hash).to include(activated: true)
      end

    end

  end

  describe "#to_hash" do

    subject { scenario.to_hash }

    it "includes the name of the scenario" do
      expect(subject).to include(name: name)
    end

    context "when the scenario is unchanged" do

      it "includes an activated flag that is false" do
        expect(scenario.to_hash).to include(activated: false)
      end

      it "includes stubs that are empty" do
        expect(scenario.to_hash).to include(stubs: [])
      end

      it "includes triggered scenario names that are empty" do
        expect(scenario.to_hash).to include(triggered_scenario_names: [])
      end

    end

  end

end
