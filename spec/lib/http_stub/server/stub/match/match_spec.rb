describe HttpStub::Server::Stub::Match::Match do

  let(:stub)    { instance_double(HttpStub::Server::Stub::Stub) }
  let(:request) { instance_double(HttpStub::Server::Request) }

  let(:stub_match) { HttpStub::Server::Stub::Match::Match.new(stub, request) }

  describe "#stub" do

    subject { stub_match.stub }

    context "when a stub is provided" do

      it "exposes the provided value" do
        expect(subject).to eql(stub)
      end

    end

    context "when a stub is not provided" do

      let(:stub_match) { HttpStub::Server::Stub::Match::Match.new(nil, request) }

      it "returns the empty stub" do
        expect(subject).to eql(HttpStub::Server::Stub::Empty::INSTANCE)
      end

    end

  end

  describe "#request" do

    it "exposes the provided value" do
      expect(stub_match.request).to eql(request)
    end

  end

end
