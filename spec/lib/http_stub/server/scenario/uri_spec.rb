describe HttpStub::Server::Scenario::Uri do

  describe "::create" do

    let(:name) { "without_escape_characters" }

    subject { described_class.create(name) }

    it "returns a uri starting with '/http_stub/scenarios'" do
      expect(subject).to start_with("/http_stub/scenarios")
    end

    it "returns a uri ending with a name parameter" do
      expect(subject).to end_with("?name=without_escape_characters")
    end

    context "when the name contains characters requiring URI escaping" do

      let(:name) { "contains characters!to?be&escaped" }

      it "returns a uri with the name uri escaped" do
        expect(subject).to end_with("?name=contains+characters%21to%3Fbe%26escaped")
      end

    end

  end

end
