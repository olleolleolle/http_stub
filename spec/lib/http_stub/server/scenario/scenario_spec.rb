describe HttpStub::Server::Scenario::Scenario do

  let(:name)            { "Some scenario name" }
  let(:number_of_stubs) { 3 }
  let(:stubs)           { (1..number_of_stubs).map { instance_double(HttpStub::Server::Stub::Stub) } }

  let(:number_of_triggered_scenario_names) { 3 }
  let(:triggered_scenario_names)           do
    (1..number_of_triggered_scenario_names).map { |i| "Triggered Scenario Name #{i}" }
  end
  let(:triggered_scenarios)                do
    (1..number_of_triggered_scenario_names).map { instance_double(HttpStub::Server::Scenario::Trigger) }
  end

  let(:args) do
    HttpStub::ScenarioFixture.new.
      with_name!(name).
      with_stubs!(number_of_stubs).
      with_triggered_scenario_names!(triggered_scenario_names).
      server_payload
  end

  let(:scenario) { described_class.new(args) }

  describe "#constructor" do

    subject { scenario }

    context "when many stub payloads are provided" do

      let(:number_of_stubs) { 3 }

      it "creates an underlying stub for each stub payload provided" do
        args["stubs"].each { |stub_args| expect(HttpStub::Server::Stub).to receive(:create).with(stub_args) }

        subject
      end

    end

    context "when one stub payload is provided" do

      let(:number_of_stubs) { 1 }

      it "creates an underlying stub for the stub payload provided" do
        expect(HttpStub::Server::Stub).to receive(:create).with(args["stubs"].first)

        subject
      end

    end

    context "when many triggered scenario names are provided" do

      let(:number_of_triggered_scenario_names) { 3 }

      it "creates a scenario trigger for each trigger name provided" do
        triggered_scenario_names.each do |scenario_name|
          expect(HttpStub::Server::Scenario::Trigger).to receive(:new).with(scenario_name)
        end

        subject
      end

    end

    context "when no triggered scenario names are provided" do

      let(:number_of_triggered_scenario_names) { 0 }

      it "does not create a scenario trigger" do
        expect(HttpStub::Server::Scenario::Trigger).to_not receive(:new)

        subject
      end

    end

  end

  describe "#matches?" do

    let(:logger) { instance_double(Logger) }

    subject { scenario.matches?(other_name, logger) }

    describe "when the scenarios name exactly matches the provided name" do

      let(:other_name) { name }

      it "returns true" do
        expect(subject).to be(true)
      end

    end

    describe "when the scenarios name is a substring of the provided name" do

      let(:other_name) { "#{name} With Additional Context" }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

    describe "when the scenarios name is completely different to the provided name" do

      let(:other_name) { "Completely Different Scenario Name" }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

  end

  describe "#links" do

    subject { scenario.links }

    before(:example) { allow(HttpStub::Server::Scenario::Links).to receive(:new) }

    it "create links for the scenario name" do
      expect(HttpStub::Server::Scenario::Links).to receive(:new).with(name)

      subject
    end

    it "returns the created links" do
      links = instance_double(HttpStub::Server::Scenario::Links)
      allow(HttpStub::Server::Scenario::Links).to receive(:new).and_return(links)

      expect(subject).to eql(links)
    end

  end

  describe "#stubs" do

    before(:example) { allow(HttpStub::Server::Stub).to receive(:create).and_return(*stubs) }

    it "returns the HttpStub::Server::Stub's constructed from the scenario's arguments" do
      expect(scenario.stubs).to eql(stubs)
    end

  end

  describe "#triggered_scenarios" do

    before(:example) { allow(HttpStub::Server::Scenario::Trigger).to receive(:new).and_return(*triggered_scenarios) }

    it "returns the triggered scenarios constructed from the scenario's arguments" do
      expect(scenario.triggered_scenarios).to eql(triggered_scenarios)
    end

  end

  describe "#to_s" do

    it "returns the string representation of the activation arguments" do
      expect(args).to receive(:to_s).and_return("scenario string representation")

      expect(scenario.to_s).to eql("scenario string representation")
    end

  end

end
