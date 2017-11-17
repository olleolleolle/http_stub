describe HttpStub::Server::Memory::InitialState do

  let(:scenario_hashes)    { (1..3).map { HttpStub::Configurator::ScenarioFixture.create_hash } }
  let(:stub_hashes)        { (1..3).map { HttpStub::Configurator::StubFixture.create_hash } }
  let(:configurator_state) do
    instance_double(HttpStub::Configurator::State, scenario_hashes: scenario_hashes, stub_hashes: stub_hashes)
  end

  let(:initial_state) { described_class.new(configurator_state) }

  describe "#load_scenarios" do

    subject { initial_state.load_scenarios }

    it "returns the provided scenarios" do
      expected_scenario_names = scenario_hashes.map { |hash| hash[:name] }.reverse

      expect(subject.map(&:name)).to contain_exactly(*expected_scenario_names)
    end

  end

  describe "#load_stubs" do

    let(:scenario_registry) { HttpStub::Server::Scenario::Registry.new(scenarios) }

    subject { initial_state.load_stubs(scenario_registry) }

    context "when scenarios have been activated" do

      let(:scenarios) { (1..3).map { |i| HttpStub::Server::ScenarioFixture.with_stubs(activated: i % 2 > 0) } }

      it "contains the provided stubs and those activated by each activated scenario" do
        activated_stubs = [ scenarios.first, scenarios.last ].map(&:stubs).flatten

        expect_stub_ids_to_contain_exactly(stub_hashes.map { |hash| hash[:id] } + activated_stubs.map(&:stub_id))
      end

    end

    context "when no scenarios have been activated" do

      let(:scenarios) { (1..3).map { HttpStub::Server::ScenarioFixture.create(activated: false) } }

      it "returns the provided stubs" do
        expect_stub_ids_to_contain_exactly(stub_hashes.map { |hash| hash[:id] })
      end

    end

    def expect_stub_ids_to_contain_exactly(expected_ids)
      expect(subject.map(&:stub_id)).to contain_exactly(*expected_ids)
    end

  end

end
