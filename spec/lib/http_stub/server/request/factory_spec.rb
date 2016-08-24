describe HttpStub::Server::Request::Factory do

  let(:scenario_registry)     { instance_double(HttpStub::Server::Registry) }
  let(:session_configuration) { { some_configuration_key: "some configuration value" } }

  let(:rack_request) { Rack::RequestFixture.create }

  let(:factory) { described_class.new(scenario_registry, session_configuration) }

  describe "constructor" do




  end

  describe "#create" do

    let(:session_factory) { instance_double(HttpStub::Server::Session::Factory, create: session) }
    let(:session)         { instance_double(HttpStub::Server::Session::Session) }

    let(:created_request) { instance_double(HttpStub::Server::Request::Request, "session=" => nil) }

    subject { factory.create(rack_request) }

    before(:example) { allow(HttpStub::Server::Session::Factory).to receive(:new).and_return(session_factory) }

    it "creates a request for the rack request" do
      expect(HttpStub::Server::Request::Request).to receive(:new).with(rack_request).and_return(created_request)

      subject
    end

    it "creates a session factory using the factories scenario registry and configuration" do
      expect(HttpStub::Server::Session::Factory).to receive(:new).with(scenario_registry, session_configuration)

      subject
    end

    it "creates a session for the request via the session factory" do
      allow(HttpStub::Server::Request::Request).to receive(:new).and_return(created_request)
      expect(session_factory).to receive(:create).with(created_request)

      subject
    end

    it "establishes the session on the request" do
      expect(subject.session).to eql(session)
    end

    it "returns the created request" do
      allow(HttpStub::Server::Request::Request).to receive(:new).and_return(created_request)

      expect(subject).to eql(created_request)
    end

  end

end
