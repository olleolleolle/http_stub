describe HttpStub::Server::Session::Controller do

  let(:session_registry) { instance_double(HttpStub::Server::Registry) }

  let(:controller) { described_class.new(session_registry) }

  describe "#find" do

    let(:id)                 { "Some session id" }
    let(:request_parameters) { { id: id } }
    let(:request)            { instance_double(HttpStub::Server::Request::Request, parameters: request_parameters)}
    let(:logger)             { instance_double(::Logger) }

    subject { controller.find(request, logger) }

    it "finds a session in the reigstry with a matching session id" do
      expect(session_registry).to receive(:find).with(id, logger)

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

    it "retrieves all sessions in the reigstry" do
      expect(session_registry).to receive(:all)

      subject
    end

    it "returns the sessions" do
      sessions = (1..3).map { instance_double(HttpStub::Server::Session::Session) }
      allow(session_registry).to receive(:all).and_return(sessions)

      expect(subject).to eql(sessions)
    end

  end

end
