describe HttpStub::Server::Scenario::Uri do

  describe "::create" do

    subject { described_class.create }

    it "returns a generic activation uri" do
      expect(subject).to eql("/http_stub/scenarios/activate")
    end

  end

end
