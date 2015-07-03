describe HttpStub::Server::Stub::Match::TruthyMatcher do

  let(:truthy_matcher) { described_class }

  describe "::matches?" do

    let(:request) { instance_double(HttpStub::Server::Request) }
    let(:logger)  { instance_double(Logger) }

    it "returns true" do
      expect(truthy_matcher.matches?(request, logger)).to be(true)
    end

  end

  describe "::to_s" do

    it "returns an empty string" do
      expect(truthy_matcher.to_s).to eql("")
    end

  end

end
