describe HttpStub::Server::Stub::TruthyRequestMatcher do

  let(:truthy_request_matcher) { HttpStub::Server::Stub::TruthyRequestMatcher }

  describe "::match?" do

    let(:request) { instance_double(Rack::Request) }

    it "returns true" do
      expect(truthy_request_matcher.match?(request)).to be(true)
    end

  end

  describe "::to_s" do

    it "returns an empty string" do
      expect(truthy_request_matcher.to_s).to eql("")
    end

  end

end
