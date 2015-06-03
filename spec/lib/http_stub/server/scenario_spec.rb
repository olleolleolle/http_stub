describe HttpStub::Server::Scenario do

  let(:args) { HttpStub::ScenarioFixture.new.server_payload }

  describe "::create" do

    subject { HttpStub::Server::Scenario.create(args) }

    it "creates a scenario instance with the provided arguments" do
      expect(HttpStub::Server::Scenario::Instance).to receive(:new).with(args)

      subject
    end

    it "returns the created scenario" do
      scenario = instance_double(HttpStub::Server::Scenario::Instance)
      allow(HttpStub::Server::Scenario::Instance).to receive(:new).and_return(scenario)

      expect(subject).to eql(scenario)
    end

  end

end
