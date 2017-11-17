describe HttpStub::Server::Stub::Match::Miss do

  let(:request) { HttpStub::Server::RequestFixture.create }

  let(:miss) { described_class.new(request) }

  describe "#request" do

    it "exposes the provided value" do
      expect(miss.request).to eql(request)
    end

  end

end
