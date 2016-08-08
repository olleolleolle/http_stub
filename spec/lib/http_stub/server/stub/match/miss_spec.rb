describe HttpStub::Server::Stub::Match::Miss do

  let(:request)  { instance_double(HttpStub::Server::Request::Request) }

  let(:miss) { HttpStub::Server::Stub::Match::Miss.new(request) }

  describe "#request" do

    it "exposes the provided value" do
      expect(miss.request).to eql(request)
    end

  end

end
