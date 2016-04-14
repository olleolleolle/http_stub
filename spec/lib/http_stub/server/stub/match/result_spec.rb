describe HttpStub::Server::Stub::Match::Result do

  let(:request) { instance_double(HttpStub::Server::Request) }
  let(:stub)    { instance_double(HttpStub::Server::Stub::Stub) }

  let(:stub_match) { HttpStub::Server::Stub::Match::Result.new(request, stub) }

  describe "#request" do

    it "exposes the provided value" do
      expect(stub_match.request).to eql(request)
    end

  end

  describe "#stub" do

    it "exposes the provided value" do
      expect(stub_match.stub).to eql(stub)
    end

  end

end
