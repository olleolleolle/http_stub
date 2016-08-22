describe HttpStub::Server::Request::Factory do

  let(:scenario_registry) { instance_double(HttpStub::Server::Registry) }

  let(:rack_request) { Rack::RequestFixture.create }

  let(:factory) { described_class.new(scenario_registry) }

  describe "::create" do

    let(:session) { instance_double(HttpStub::Server::Session) }

    subject { factory.create(rack_request) }

    it "creates a request for the rack request" do
      expect(HttpStub::Server::Request::Request).to receive(:new).with(rack_request, anything)

      subject
    end

    it "creates a session" do
      expect(HttpStub::Server::Session).to receive(:new).with(scenario_registry)

      subject
    end

    it "creates a session that is shared across all requests" do
      allow(HttpStub::Server::Session).to receive(:new).once.and_return(session)
      rack_requests = (1..3).map { Rack::RequestFixture.create }

      requests = rack_requests.map { |rack_request| factory.create(rack_request) }

      requests.each { |request| expect(request.session).to eql(session) }
    end

    it "returns the created request" do
      http_stub_request = instance_double(HttpStub::Server::Request::Request)
      allow(HttpStub::Server::Request::Request).to receive(:new).and_return(http_stub_request)

      expect(subject).to eql(http_stub_request)
    end

  end

end
