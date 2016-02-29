describe HttpStub::Server::Scenario::Links do

  let(:name) { "without_esacpe_characters" }

  let(:links) { described_class.new(name) }

  describe "#detail" do

    subject { links.detail }

    it "returns a uri starting with '/http_stub/scenarios'" do
      expect(subject).to start_with("/http_stub/scenarios")
    end

    it "returns a uri ending with a name parameter" do
      expect(subject).to end_with("?name=#{name}")
    end

    context "when the name contains characters requiring uri escaping" do

      let(:name) { "contains characters!to?be&escaped" }

      it "returns a uri with the name uri escaped" do
        expect(subject).to end_with("?name=contains+characters%21to%3Fbe%26escaped")
      end

    end

  end

  describe "#activate" do

    subject { links.activate }

    it "returns a generic activation link" do
      expect(subject).to eql("/http_stub/scenarios/activate")
    end

  end

end
