describe HttpStub::Server::Scenario::Registry do

  let(:scenarios) { (1..3).map { HttpStub::Server::ScenarioFixture.create } }

  let(:logger) { HttpStub::Server::SilentLogger }

  let(:scenario_registry) { described_class.new(scenarios) }

  shared_context "mocked underlying registry" do

    let(:underlying_scenario_registry) { instance_double(HttpStub::Server::Registry) }

    before(:example) { allow(HttpStub::Server::Registry).to receive(:new).and_return(underlying_scenario_registry) }

  end

  it "uses an underlying simple registry that is initialised with the provided scenarios" do
    expect(HttpStub::Server::Registry).to receive(:new).with("scenario", scenarios)

    scenario_registry
  end

  describe "#find" do
    include_context "mocked underlying registry"

    let(:name) { "some scenario name" }

    let(:found_scenario) { scenarios.last }

    subject { scenario_registry.find(name, logger) }

    before(:example) { allow(underlying_scenario_registry).to receive(:find).and_return(found_scenario) }

    it "delegates to an underlying simple registry" do
      expect(underlying_scenario_registry).to receive(:find).with(name, logger)

      subject
    end

    it "returns any found scenario" do
      expect(subject).to eql(found_scenario)
    end

  end

  describe "#find_all" do

    subject { scenario_registry.find_all { |scenario| matching_scenarios.include?(scenario) } }

    context "when some scenarios match" do

      let(:matching_scenarios) { [ scenarios.first, scenarios.last ] }

      it "returns the matching scenarios" do
        expect(subject).to contain_exactly(*matching_scenarios)
      end

    end

    context "when no scenarios match" do

      let(:matching_scenarios) { [] }

      it "returns an empty array" do
        expect(subject).to eql([])
      end

    end

  end

  describe "#all" do
    include_context "mocked underlying registry"

    let(:all_scenarios) { (1..3).map { HttpStub::Server::ScenarioFixture.create } }

    subject { scenario_registry.all }

    before(:example) { allow(underlying_scenario_registry).to receive(:all).and_return(all_scenarios) }

    it "delegates to an underlying simple registry" do
      expect(underlying_scenario_registry).to receive(:all)

      subject
    end

    it "returns the result from the underlying registry" do
      expect(subject).to eql(all_scenarios)
    end

  end

  describe "#stubs_activated_by" do

    let(:scenario)        do
      HttpStub::Server::ScenarioFixture.with_stubs(
        triggered_scenario_names: scenarios_triggered_names
      )
    end
    let(:other_scenarios) { (1..3).map { HttpStub::Server::ScenarioFixture.with_stubs } }

    subject { scenario_registry.stubs_activated_by(scenario, logger) }

    context "when the scenario has no triggers" do

      let(:scenarios)                 { [ scenario ] + other_scenarios }
      let(:scenarios_triggered_names) { [] }

      it "returns the scenario's stubs" do
        expect(subject).to eql(scenario.stubs)
      end

    end

    context "when the scenario has triggers which are nested" do

      let(:scenarios_triggered_names)       { (1..3).map { |i| "trigger_#{i}" } }
      let(:nested_scenario_triggered_names) { (1..3).map { |i| (1..3).map { |j| "nested_trigger_#{i}_#{j}" } } }

      let(:scenarios_triggered)             do
        scenarios_triggered_names.each_with_index.map do |trigger_name, i|
          HttpStub::Server::ScenarioFixture.with_stubs(
            name:                     trigger_name,
            triggered_scenario_names: nested_scenario_triggered_names[i]
          )
        end
      end

      let(:nested_scenarios_triggered) do
        nested_scenario_triggered_names.map do |trigger_names|
          trigger_names.map { |trigger_name| HttpStub::Server::ScenarioFixture.with_stubs(name: trigger_name) }
        end.flatten
      end

      let(:scenarios) { [ scenario ] + other_scenarios + scenarios_triggered + nested_scenarios_triggered }

      it "returns the stubs from the scenario and all triggered scenario's" do
        active_scenarios = [ scenario, scenarios_triggered, nested_scenarios_triggered ].flatten

        expect(subject).to contain_exactly(*active_scenarios.map(&:stubs).flatten)
      end

    end

  end

end
