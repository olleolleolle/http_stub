describe HttpStub::Server::Scenario::Trigger do

  let(:name) { "Some Scenario Name" }

  let(:trigger) { described_class.new(name) }

  describe "#name" do

    subject { trigger.name }

    it "returns the provided name" do
      expect(subject).to eql(name)
    end

  end

  describe "#uri" do

    let(:created_uri) { "/some/scenario/uri" }

    subject { trigger.uri }

    before(:example) { allow(HttpStub::Server::Scenario::Uri).to receive(:create).and_return(created_uri) }

    it "creates a uri based on the name of the scenario" do
      expect(HttpStub::Server::Scenario::Uri).to receive(:create).with(name)

      subject
    end

    it "returns the created uri" do
      expect(subject).to eql(created_uri)
    end

  end

end
