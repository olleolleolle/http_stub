describe HttpStub::Server::Scenario::Scenario do

  let(:name)                     { "some_scenario_name" }
  let(:number_of_stubs)          { 3 }
  let(:stubs)                    { (1..number_of_stubs).map { instance_double(HttpStub::Server::Stub::Stub) } }
  let(:triggered_scenario_names) { (1..3).map { |i| "triggered/scenario/name/#{i}" } }
  let(:args) do
    HttpStub::ScenarioFixture.new.with_name!(name).
      with_stubs!(number_of_stubs).
      with_triggered_scenario_names!(triggered_scenario_names).
      server_payload
  end

  let(:scenario) { HttpStub::Server::Scenario::Scenario.new(args) }

  before(:example) { allow(HttpStub::Server::Stub).to receive(:create).and_return(*stubs) }

  describe "#constructor" do

    context "when many stub payloads are provided" do

      let(:number_of_stubs) { 3 }

      it "creates an underlying stub for each stub payload provided" do
        args["stubs"].each { |stub_args| expect(HttpStub::Server::Stub).to receive(:create).with(stub_args) }

        scenario
      end

    end

    context "when one stub payload is provided" do

      let(:number_of_stubs) { 1 }

      it "creates an underlying stub for each stub payload provided" do
        expect(HttpStub::Server::Stub).to receive(:create).with(args["stubs"].first)

        scenario
      end

    end

  end

  describe "#matches?" do

    let(:logger) { instance_double(Logger) }

    subject { scenario.matches?(other_name, logger) }

    describe "when the scenario's name exactly matches the provided name" do

      let(:other_name) { name }

      it "returns true" do
        expect(subject).to be(true)
      end

    end

    describe "when the scenario's name is a substring of the provided name" do

      let(:other_name) { "#{name}_with_additional_context" }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

    describe "when the scenario's name is completely different to the provided name" do

      let(:other_name) { "completely_different_scenario_name" }

      it "returns false" do
        expect(subject).to be(false)
      end

    end

  end

  describe "#uri" do

    it "returns the scenario's name with '/' prefixed" do
      expect(scenario.uri).to eql("/#{name}")
    end

  end

  describe "#detail_uri" do

    it "returns the scenario's name with '/' prefixed" do
      expect(scenario.detail_uri).to eql("/http_stub/scenarios/#{name}")
    end

  end

  describe "#stubs" do

    it "returns the HttpStub::Server::Stub's constructed from the scenario's arguments" do
      expect(scenario.stubs).to eql(stubs)
    end

  end

  describe "#triggered_scenario_names" do

    it "returns the value provided in the payload" do
      expect(scenario.triggered_scenario_names).to eql(triggered_scenario_names)
    end

  end

  describe "#triggered_scenarios" do

    it "returns an array containing the triggered scenario names and uris" do
      expected_details = triggered_scenario_names.reduce([]) { |result, name| result << [name, "/#{name}"] }

      expect(scenario.triggered_scenarios).to eql(expected_details)
    end

  end

  describe "#to_s" do

    it "returns the string representation of the activation arguments" do
      expect(args).to receive(:to_s).and_return("scenario string representation")

      expect(scenario.to_s).to eql("scenario string representation")
    end

  end

end
