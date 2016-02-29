describe HttpStub::Server::Scenario::Trigger do

  let(:name) { "Some Scenario Name" }

  let(:trigger) { described_class.new(name) }

  describe "#name" do

    subject { trigger.name }

    it "returns the provided name" do
      expect(subject).to eql(name)
    end

  end

  describe "#links" do

    subject { trigger.links }

    it "creates links based on the scenario's name" do
      expect(HttpStub::Server::Scenario::Links).to receive(:new).with(name)

      subject
    end

    it "returns the created links" do
      links = instance_double(HttpStub::Server::Scenario::Links)
      allow(HttpStub::Server::Scenario::Links).to receive(:new).and_return(links)

      expect(subject).to eql(links)
    end

  end

end
