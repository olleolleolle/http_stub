describe HttpStub::Server::Request do

  let(:rack_request) { instance_double(Rack::Request) }

  describe "::create" do

    subject { described_class.create(rack_request) }

    it "creates a request for the rack request" do
      expect(HttpStub::Server::Request::Request).to receive(:new).with(rack_request)

      subject
    end

    it "returns the created request" do
      http_stub_request = instance_double(HttpStub::Server::Request::Request)
      allow(HttpStub::Server::Request::Request).to receive(:new).and_return(http_stub_request)

      expect(subject).to eql(http_stub_request)
    end

  end

end
