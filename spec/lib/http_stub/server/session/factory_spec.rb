describe HttpStub::Server::Session::Factory do

  let(:session_configuration) { { some_configured_key: "some configured value" } }
  let(:session_registry)      { instance_double(HttpStub::Server::Registry) }
  let(:scenario_registry)     { instance_double(HttpStub::Server::Registry) }

  let(:identifier_strategy) { instance_double(HttpStub::Server::Session::IdentifierStrategy) }

  let(:factory) { described_class.new(session_configuration, session_registry, scenario_registry) }

  before(:example) do
    allow(HttpStub::Server::Session::IdentifierStrategy).to receive(:new).and_return(identifier_strategy)
  end

  describe "constructor" do

    subject { factory }

    it "creates a session identifier strategy based on the provided configuration" do
      expect(HttpStub::Server::Session::IdentifierStrategy).to receive(:new).with(session_configuration)

      subject
    end

  end

  describe "#create" do

    let(:request)            { instance_double(HttpStub::Server::Request::Request) }
    let(:logger)             { instance_double(::Logger) }
    let(:session_identifier) { "Some session identifier" }

    let(:found_session) { instance_double(HttpStub::Server::Session::Session) }

    subject { factory.create(request, logger) }

    before(:example) do
      allow(identifier_strategy).to receive(:identifier_for).and_return(session_identifier)
      allow(session_registry).to receive(:find).and_return(found_session)
    end

    it "determines the session identifier for the request" do
      expect(identifier_strategy).to receive(:identifier_for).with(request)

      subject
    end

    it "finds any session in the session registry that has the determined identifier" do
      expect(session_registry).to receive(:find).with(session_identifier, logger)

      subject
    end

    context "when a session is found" do

      let(:found_session) { instance_double(HttpStub::Server::Session::Session) }

      it "does not create a new session" do
        expect(HttpStub::Server::Session::Session).to_not receive(:new)

        subject
      end

      it "returns the session" do
        expect(subject).to eql(found_session)
      end

    end

    context "when a session is not found" do

      let(:found_session)   { nil }
      let(:created_session) { instance_double(HttpStub::Server::Session::Session) }

      before(:example) do
        allow(HttpStub::Server::Session::Session).to receive(:new).and_return(created_session)
        allow(session_registry).to receive(:add)
      end

      it "creates a session with the determined identifier" do
        expect(HttpStub::Server::Session::Session).to receive(:new).with(session_identifier, scenario_registry)

        subject
      end

      it "adds the session to the session registry" do
        expect(session_registry).to receive(:add).with(created_session, logger)

        subject
      end

      it "returns the created session" do
        expect(subject).to eql(created_session)
      end

    end

  end

end
