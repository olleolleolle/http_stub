describe HttpStub::Server::Session::Empty do

  describe "::stubs" do

    subject { described_class.stubs }

    it "returns an empty array" do
      expect(subject).to eql([])
    end

  end

end
