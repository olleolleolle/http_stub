describe HttpStub::Client::Client do

  let(:server_uri) { "/some/server/uri" }

  let(:server)          { instance_double(HttpStub::Client::Server) }
  let(:default_session) { instance_double(HttpStub::Client::Session) }

  let(:client) { described_class.new(server_uri) }

  before(:example) do
    allow(HttpStub::Client::Server).to receive(:new).and_return(server)
    allow(HttpStub::Client::Session).to receive(:new).and_return(default_session)
  end

  it "creates a server for the requests issued by the client supplying the server URI" do
    expect(HttpStub::Client::Server).to receive(:new).with(server_uri)

    client
  end

  it "creates a default session which the client uses when sessions are not used" do
    expect(HttpStub::Client::Session).to receive(:new)

    client
  end

  it "creates a default session identified as the transactional session" do
    expect(HttpStub::Client::Session).to receive(:new).with("http_stub_transactional", anything)

    client
  end

  it "creates a default session that uses the server to issue requests" do
    expect(HttpStub::Client::Session).to receive(:new).with(anything, server)

    client
  end

  describe "#session" do

    let(:session_id) { "some session id" }

    let(:session) { instance_double(HttpStub::Client::Session) }

    subject { client.session(session_id) }

    before(:example) { allow(HttpStub::Client::Session).to receive(:new).and_return(session) }

    it "creates a session for the provided ID" do
      expect(HttpStub::Client::Session).to receive(:new).with(session_id, anything)

      subject
    end

    it "creates a session that uses the server to issue requests" do
      expect(HttpStub::Client::Session).to receive(:new).with(anything, server)

      subject
    end

    it "returns the created session" do
      expect(subject).to eql(session)
    end

  end

  describe "#activate!" do

    let(:scenario_name) { "Some scenario name" }

    subject { client.activate!(scenario_name) }

    it "delegates to the default session" do
      expect(default_session).to receive(:activate!).with(scenario_name)

      subject
    end

  end

  describe "#reset!" do

    let(:request) { instance_double(HttpStub::Client::Request::Basic) }

    subject { client.reset! }

    before(:example) { allow(server).to receive(:submit!) }

    it "submits a delete request" do
      expect(server).to receive(:submit!).with(hash_including(method: :delete))

      subject
    end

    it "submits a request to the sessions endpoint" do
      expect(server).to receive(:submit!).with(hash_including(path: "sessions"))

      subject
    end

    it "describes the intent of the request as to reset the server" do
      expect(server).to receive(:submit!).with(hash_including(intent: "reset server"))

      subject
    end

  end

end
