describe HttpStub::Server::Session::Controller do

  let(:session_configuration) { instance_double(HttpStub::Server::Session::Configuration) }
  let(:session_registry)      { instance_double(HttpStub::Server::Session::Registry) }
  let(:server_memory)         { instance_double(HttpStub::Server::Memory::Memory, sessions: session_registry) }

  let(:session_id) { "some session id" }
  let(:request)    { instance_double(HttpStub::Server::Request::Request, session_id: session_id) }
  let(:logger)     { instance_double(Logger) }

  let(:controller) { described_class.new(session_configuration, server_memory) }

  describe "#find" do

    subject { controller.find(request, logger) }

    it "finds a session in the servers session registry with a session id matching that in the request" do
      expect(session_registry).to receive(:find).with(session_id, logger)

      subject
    end

    it "returns any found session" do
      session = instance_double(HttpStub::Server::Session::Session)
      allow(session_registry).to receive(:find).and_return(session)

      expect(subject).to eql(session)
    end

  end

  describe "#find_all" do

    subject { controller.find_all }

    it "retrieves all sessions in the servers session reigstry" do
      expect(session_registry).to receive(:all)

      subject
    end

    it "returns the sessions" do
      sessions = (1..3).map { instance_double(HttpStub::Server::Session::Session) }
      allow(session_registry).to receive(:all).and_return(sessions)

      expect(subject).to eql(sessions)
    end

  end

  describe "#mark_default" do

    subject { controller.mark_default(request) }

    it "establishes the default session identifier in the servers session configuration" do
      expect(session_configuration).to receive(:default_identifier=).with(session_id)

      subject
    end

  end

  describe "#delete" do

    subject { controller.delete(request, logger) }

    it "deletes the session identified in the request from servers session registry" do
      expect(session_registry).to receive(:delete).with(session_id, logger)

      subject
    end

  end

  describe "#clear" do

    subject { controller.clear(logger) }

    it "delegates to the servers session registry" do
      expect(session_registry).to receive(:clear).with(logger)

      subject
    end

  end

end
