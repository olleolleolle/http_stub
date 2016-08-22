describe HttpStub::Server::Session do

  let(:scenario_registry)   { instance_double(HttpStub::Server::Registry) }
  let(:stub_registry)       { instance_double(HttpStub::Server::Stub::Registry) }
  let(:stub_match_registry) { instance_double(HttpStub::Server::Registry) }
  let(:stub_miss_registry)  { instance_double(HttpStub::Server::Registry) }

  let(:logger) { instance_double(Logger) }

  let(:session) { described_class.new(scenario_registry) }

  before(:example) do
    allow(HttpStub::Server::Stub::Registry).to receive(:new).and_return(stub_registry)
    allow(HttpStub::Server::Registry).to receive(:new).with("stub match").and_return(stub_match_registry)
    allow(HttpStub::Server::Registry).to receive(:new).with("stub miss").and_return(stub_miss_registry)
  end

  describe "activate_scenario!" do

    let(:scenario_name) { "Some scenario name" }
    let(:scenario)      { nil }

    subject { session.activate_scenario!(scenario_name, logger) }

    before(:example) { allow(scenario_registry).to receive(:find).with(scenario_name, anything).and_return(scenario) }

    it "attempts to retrieve the scenario with the provided name from the scenario registry" do
      expect(scenario_registry).to receive(:find).with(scenario_name, logger)

      subject rescue nil
    end

    context "when the scenario is found" do

      let(:scenario_trigger_names) { (1..3).map { |i| "scenario trigger #{i}" } }
      let(:scenario_triggers)      do
        scenario_trigger_names.map { |name| instance_double(HttpStub::Server::Scenario::Trigger, name: name) }
      end
      let(:triggered_scenarios)    do
        (1..3).map { instance_double(HttpStub::Server::Scenario::Scenario, triggered_scenarios: [], stubs: []) }
      end
      let(:scenario_stubs)         { (1..3).map { instance_double(HttpStub::Server::Stub::Stub) } }
      let(:scenario)               do
        instance_double(HttpStub::Server::Scenario::Scenario, triggered_scenarios: scenario_triggers,
                                                              stubs:               scenario_stubs)
      end

      before(:example) do
        scenario_trigger_names.zip(triggered_scenarios).each do |scenario_trigger_name, triggered_scenario|
          allow(scenario_registry).to(
            receive(:find).with(scenario_trigger_name, anything).and_return(triggered_scenario)
          )
        end
        allow(stub_registry).to receive(:concat)
      end

      it "triggers activation of the scenario triggers of the scenario" do
        scenario_trigger_names.zip(triggered_scenarios).each do |scenario_trigger_name, triggered_scenario|
          expect(scenario_registry).to receive(:find).with(scenario_trigger_name, logger).and_return(triggered_scenario)
        end

        subject
      end

      it "adds the scenarios stubs to the stub registry" do
        expect(stub_registry).to receive(:concat).with(scenario_stubs, logger)

        subject
      end

    end

    context "when the scenario is not found" do

      let(:scenario) { nil }

      it "raises a scenario not found error with the provided name" do
        expect { subject }.to raise_error(HttpStub::Server::Scenario::NotFoundError, /#{scenario_name}/)
      end

    end

  end

  describe "#add_stub" do

    let(:the_stub) { instance_double(HttpStub::Server::Stub::Stub) }

    subject { session.add_stub(the_stub, logger) }

    it "adds the provided stub to the stub regsitry" do
      expect(stub_registry).to receive(:add).with(the_stub, logger)

      subject
    end

  end

  describe "#find_stub" do

    let(:id)       { SecureRandom.uuid }
    let(:the_stub) { instance_double(HttpStub::Server::Stub::Stub) }

    subject { session.find_stub(id, logger) }

    before(:example) { allow(stub_registry).to receive(:find).and_return(the_stub) }

    it "finds the stub with the provided id in the stub regsitry" do
      expect(stub_registry).to receive(:find).with(id, logger)

      subject
    end

    it "returns any found stub in the stub regsitry" do
      expect(subject).to eql(the_stub)
    end

  end

  describe "#stubs" do

    let(:the_stubs) { (1..3).map { instance_double(HttpStub::Server::Stub::Stub) } }

    subject { session.stubs }

    before(:example) { allow(stub_registry).to receive(:all).and_return(the_stubs) }

    it "finds all stubs in the stub regsitry" do
      expect(stub_registry).to receive(:all)

      subject
    end

    it "returns the stubs in the stub regsitry" do
      expect(subject).to eql(the_stubs)
    end

  end

  describe "#match" do

    let(:request) { instance_double(HttpStub::Server::Request::Request) }

    let(:matched_stub) { instance_double(HttpStub::Server::Stub::Stub) }

    subject { session.match(request, logger) }

    before(:example) { allow(stub_registry).to receive(:match).and_return(matched_stub) }

    it "delegates to the stub registry to match the request with a stub" do
      expect(stub_registry).to receive(:match).with(request, logger)

      subject
    end

    it "returns any matched stub" do
      expect(subject).to eql(matched_stub)
    end

  end

  describe "#add_match" do

    let(:triggered_scenario_names) { [] }
    let(:triggered_stubs)          { [] }
    let(:match_stub_triggers)      do
      instance_double(HttpStub::Server::Stub::Triggers, scenario_names: triggered_scenario_names,
                                                        stubs:          triggered_stubs)
    end
    let(:match_stub)               do
      instance_double(HttpStub::Server::Stub::Stub, triggers: match_stub_triggers)
    end
    let(:match)                    { instance_double(HttpStub::Server::Stub::Match::Match, stub: match_stub) }

    subject { session.add_match(match, logger) }

    before(:example) do
      allow(stub_match_registry).to receive(:add)
    end

    it "adds the match to the match registry" do
      expect(stub_match_registry).to receive(:add).with(match, logger)

      subject
    end

    context "when scenarios are to be triggered by the stub" do

      let(:triggered_scenario_names) { (1..3).map { |i| "triggered scenario #{i}" } }

      it "activates the scenarios in the session" do
        triggered_scenario_names.each do |scenario_name|
          expect(session).to receive(:activate_scenario!).with(scenario_name, logger)
        end

        subject
      end

    end

    context "when no scenarios are to be triggered by the stub" do

      let(:triggered_scenario_names) { [] }

      it "does not activate any scenarios in the session" do
        expect(session).to_not receive(:activate_scenario!)

        subject
      end

    end

    context "when stubs are to be triggered by the stub" do

      let(:triggered_stubs) { (1..3).map { instance_double(HttpStub::Server::Stub::Stub) } }

      it "adds the stubs to the session" do
        triggered_stubs.each { |triggered_stub| expect(session).to receive(:add_stub).with(triggered_stub, logger) }

        subject
      end

    end

    context "when no stubs are to be triggered by the stub" do

      let(:triggered_stubs) { [] }

      it "does not add any stubs to the session" do
        expect(session).to_not receive(:add_stub)

        subject
      end

    end

  end

  describe "#matches" do

    let(:stub_matches) { (1..3).map { instance_double(HttpStub::Server::Stub::Match::Match) } }

    subject { session.matches }

    before(:example) { allow(stub_match_registry).to receive(:all).and_return(stub_matches) }

    it "retrieves all the matches in the stub match registry" do
      expect(stub_match_registry).to receive(:all)

      subject
    end

    it "returns any matches" do
      expect(subject).to eql(stub_matches)
    end

  end

  describe "#last_match" do

    let(:match_args) { { uri: "some uri", method: "some method" } }

    let(:stub_match) { instance_double(HttpStub::Server::Stub::Match::Match) }

    subject { session.last_match(match_args, logger) }

    before(:example) { allow(stub_match_registry).to receive(:find).and_return(stub_match) }

    it "retrieves the match for the provided URI and method via the stub match registry" do
      expect(stub_match_registry).to receive(:find).with(match_args, logger)

      subject
    end

    it "returns any match" do
      expect(subject).to eql(stub_match)
    end

  end

  describe "#add_miss" do

    let(:stub_miss) { instance_double(HttpStub::Server::Stub::Match::Miss) }

    subject { session.add_miss(stub_miss, logger) }

    it "adds the miss to the stub miss registry" do
      expect(stub_miss_registry).to receive(:add).with(stub_miss, logger)

      subject
    end

  end

  describe "#misses" do

    let(:stub_misses) { (1..3).map { instance_double(HttpStub::Server::Stub::Match::Miss) } }

    subject { session.misses }

    before(:example) { allow(stub_miss_registry).to receive(:all).and_return(stub_misses) }

    it "retrieves all the misses in the stub miss registry" do
      expect(stub_miss_registry).to receive(:all)

      subject
    end

    it "returns any misses" do
      expect(subject).to eql(stub_misses)
    end

  end

  describe "#remember" do

    subject { session.remember }

    it "remembers the current state of the stub registry" do
      expect(stub_registry).to receive(:remember)

      subject
    end

  end

  describe "#recall" do

    subject { session.recall }

    it "recalls any last stored state in the stub registry" do
      expect(stub_registry).to receive(:recall)

      subject
    end

  end

  describe "#clear" do

    subject { session.clear(logger) }

    before(:example) do
      [ stub_registry, stub_match_registry, stub_miss_registry ].each { |registry| allow(registry).to receive(:clear) }
    end

    it "clears the stub registry" do
      expect(stub_registry).to receive(:clear).with(logger)

      subject
    end

    it "clears the stub match registry" do
      expect(stub_match_registry).to receive(:clear).with(logger)

      subject
    end

    it "clears the stub miss registry" do
      expect(stub_miss_registry).to receive(:clear).with(logger)

      subject
    end

  end

end
