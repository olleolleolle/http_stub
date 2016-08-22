describe HttpStub::Server::Stub::Triggers do

  let(:scenario_names) { (1..3).map { |i| "Scenario trigger #{i}" } }
  let(:stub_payloads)  { (1..3).map { |i| "Stub trigger payload #{i}" } }
  let(:args)           { { "scenario_names" => scenario_names, "stubs" => stub_payloads } }

  let(:stubs) { (1..stub_payloads.length).map { instance_double(HttpStub::Server::Stub::Stub) } }

  let(:triggers) { described_class.new(args) }

  before(:example) { allow(HttpStub::Server::Stub).to receive(:create).and_return(*stubs) }

  describe "::EMPTY" do

    subject { HttpStub::Server::Stub::Triggers::EMPTY }

    it "returns triggers with empty scenario names" do
      expect(subject.scenario_names).to eql([])
    end

    it "returns triggers with empty stubs" do
      expect(subject.stubs).to eql([])
    end

  end

  describe "constructor" do

    subject { described_class.new(args) }

    context "when scenario names are provided" do

      let(:args) { { "scenario_names" => scenario_names } }

      it "establishes the scenario names" do
        expect(subject.scenario_names).to eql(scenario_names)
      end

    end

    context "when scenario names are not provided" do

      let(:args) { {} }

      it "establishes an empty scenario name array" do
        expect(subject.scenario_names).to eql([])
      end

    end

    context "when stubs are provided" do

      let(:args) { { "stubs" => stub_payloads } }

      it "creates a stub for each provided stub payload" do
        stub_payloads.each { |payload| expect(HttpStub::Server::Stub).to receive(:create).with(payload) }

        subject
      end

      it "estalishes the created stubs" do
        expect(subject.stubs).to eql(stubs)
      end

    end

    context "when stubs are not provided" do

      let(:args) { {} }

      it "establishes an empty stub array" do
        expect(subject.stubs).to eql([])
      end

    end

    context "when nil args are provided" do

      let(:args) { nil }

      it "establishes an empty scenario name array" do
        expect(subject.scenario_names).to eql([])
      end

      it "establishes an empty stub array" do
        expect(subject.stubs).to eql([])
      end

    end

  end

  describe "#to_json" do

    let(:json_for_stubs)        { stubs.each_with_index.map { |i| "stub #{i} JSON" } }
    let(:quoted_json_for_stubs) { json_for_stubs.map(&:to_json) }

    subject { triggers.to_json }

    before(:example) do
      stubs.zip(quoted_json_for_stubs).each { |stub, json| allow(stub).to receive(:to_json).and_return(json) }
    end

    it "contains the scenario names" do
      expect(subject).to include_in_json(scenario_names: scenario_names)
    end

    it "contains the JSON representation of each stub" do
      expect(subject).to include_in_json(stubs: json_for_stubs)
    end

  end

  describe "#to_s" do

    subject { triggers.to_s }

    context "when scenario names and stubs are provided" do

      let(:args) { { "scenario_names" => scenario_names, "stubs" => stubs } }

      it "returns a string representation of the arguments provided to the triggers" do
        expect(subject).to eql(args.to_s)
      end

    end

    context "when scenario names and stubs are not provided" do

      let(:args) { {} }

      it "returns a string indicating the scenario names and stub are empty" do
        expect(subject).to eql({ "scenario_names" => [], "stubs" => [] }.to_s)
      end

    end

  end

end
