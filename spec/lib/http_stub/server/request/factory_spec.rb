describe HttpStub::Server::Request::Factory do

  let(:session_configuration) { instance_double(HttpStub::Server::Session::Configuration) }
  let(:session_registry)      { instance_double(HttpStub::Server::Session::Registry) }
  let(:server_memory)         { instance_double(HttpStub::Server::Memory::Memory, sessions: session_registry) }

  let(:session_identifier_strategy) { instance_double(HttpStub::Server::Session::IdentifierStrategy) }

  let(:factory) { described_class.new(session_configuration, server_memory) }

  before(:example) do
    allow(HttpStub::Server::Session::IdentifierStrategy).to receive(:new).and_return(session_identifier_strategy)
  end

  it "creates a session identifier strategy based on the session configuration" do
    expect(HttpStub::Server::Session::IdentifierStrategy).to receive(:new).with(session_configuration)

    factory
  end

  describe "#create" do

    let(:rack_request)       { Rack::RequestFixture.create }
    let(:sinatra_parameters) { { some_parameter: "some parameter value" } }
    let(:logger)             { instance_double(Logger) }

    let(:discovered_session_id) { "some session id" }
    let(:sinatra_request)       { instance_double(HttpStub::Server::Request::SinatraRequest) }
    let(:session)               { instance_double(HttpStub::Server::Session::Session) }
    let(:server_request)        { instance_double(HttpStub::Server::Request::Request) }

    subject { factory.create(rack_request, sinatra_parameters, logger) }

    before(:example) do
      allow(HttpStub::Server::Request::SinatraRequest).to receive(:new).and_return(sinatra_request)
      allow(session_identifier_strategy).to receive(:identifier_for).and_return(discovered_session_id)
      allow(session_registry).to receive(:find_or_create).and_return(session)
    end

    it "creates a sinatra request for the rack request and sinatra parameters" do
      expect(HttpStub::Server::Request::SinatraRequest).to receive(:new).with(rack_request, sinatra_parameters)

      subject
    end

    it "discovers the session identifier for the sinatra request" do
      expect(session_identifier_strategy).to receive(:identifier_for).with(sinatra_request)

      subject
    end

    it "finds or creates the session for the identifier via the servers session registry" do
      expect(session_registry).to receive(:find_or_create).with(discovered_session_id, logger)

      subject
    end

    it "creates a http_stub request containing the sinatra request" do
      expect(HttpStub::Server::Request::Request).to receive(:new).with(sinatra_request, anything, anything)

      subject
    end

    it "returns a http_stub request containing the discovered session id" do
      expect(subject.session_id).to eql(discovered_session_id)
    end

    it "returns a http_stub request containing the retrieved session" do
      expect(subject.session).to eql(session)
    end

  end

end
