describe HttpStub::Server::Stub::Match::Rule::Truthy do

  describe "::matches?" do

    let(:request) { instance_double(HttpStub::Server::Request) }
    let(:logger)  { instance_double(Logger) }

    it "returns true" do
      expect(described_class.matches?(request, logger)).to be(true)
    end

  end

  describe "::to_s" do

    it "returns an empty string" do
      expect(described_class.to_s).to eql("")
    end

  end

end
