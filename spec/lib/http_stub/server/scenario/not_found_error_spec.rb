describe HttpStub::Server::Scenario::NotFoundError do

  let(:scenario_name) { "Some scenario name" }

  let(:error) { described_class.new(scenario_name) }

  it "is a Standard Error" do
    expect(error).to be_a(::StandardError)
  end

  describe "#message" do

    subject { error.message }

    it "contains the name of the scenario" do
      expect(subject).to include(scenario_name)
    end

    it "indicates the scenario was not found" do
      expect(subject).to include("not found")
    end

  end

end
