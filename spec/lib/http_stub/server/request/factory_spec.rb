describe HttpStub::Server::Request::Factory do

  let(:session_configuration) { { some_configuration_key: "some configuration value" } }
  let(:session_registry)      { instance_double(HttpStub::Server::Registry) }
  let(:scenario_registry)     { instance_double(HttpStub::Server::Registry) }

  let(:factory) { described_class.new(session_configuration, session_registry, scenario_registry) }

  describe "constructor" do

    subject { factory }

    it "creates a session factory with the provided session configuration" do
      expect(HttpStub::Server::Session::Factory).to receive(:new).with(session_configuration, anything, anything)

      subject
    end

    it "creates a session factory with the provided registries" do
      expect(HttpStub::Server::Session::Factory).to receive(:new).with(anything, session_registry, scenario_registry)

      subject
    end

  end

  describe "#create" do

    let(:rack_request)       { Rack::RequestFixture.create }
    let(:sinatra_parameters) { { some_parameter: "some parameter value" } }
    let(:logger)             { instance_double(::Logger) }

    let(:session_factory) { instance_double(HttpStub::Server::Session::Factory, create: session) }
    let(:session)         { instance_double(HttpStub::Server::Session::Session) }

    let(:created_request) { instance_double(HttpStub::Server::Request::Request, "session=" => nil) }

    subject { factory.create(rack_request, sinatra_parameters, logger) }

    before(:example) { allow(HttpStub::Server::Session::Factory).to receive(:new).and_return(session_factory) }

    it "creates a request for the rack request and sinatra parameters" do
      expect(HttpStub::Server::Request::Request).to(
        receive(:new).with(rack_request, sinatra_parameters).and_return(created_request)
      )

      subject
    end

    it "creates a session for the request via the session factory" do
      allow(HttpStub::Server::Request::Request).to receive(:new).and_return(created_request)
      expect(session_factory).to receive(:create).with(created_request, logger)

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
