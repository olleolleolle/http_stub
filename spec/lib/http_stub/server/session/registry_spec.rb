describe HttpStub::Server::Session::Registry do

  let(:default_session_id)    { "some default session id" }
  let(:session_configuration) do
    instance_double(HttpStub::Server::Session::Configuration, default_identifier: default_session_id)
  end
  let(:scenario_registry)     { instance_double(HttpStub::Server::Registry) }
  let(:memory_session)        { instance_double(HttpStub::Server::Session::Session) }

  let(:logger)                      { instance_double(Logger) }
  let(:underlying_session_registry) { instance_double(HttpStub::Server::Registry) }

  let(:session_registry) { described_class.new(session_configuration, scenario_registry, memory_session) }

  before(:example) { allow(HttpStub::Server::Registry).to receive(:new).and_return(underlying_session_registry) }

  it "uses an underlying simple registry that is initialized with the memory session" do
    expect(HttpStub::Server::Registry).to receive(:new).with("session", [ memory_session ])

    session_registry
  end

  describe "#find" do

    let(:id) { SecureRandom.uuid }

    let(:found_session) { instance_double(HttpStub::Server::Session::Session) }

    subject { session_registry.find(id, logger) }

    before(:example) { allow(underlying_session_registry).to receive(:find).and_return(found_session) }

    it "delegates to an underlying simple registry" do
      expect(underlying_session_registry).to receive(:find).with(id, logger)

      subject
    end

    it "returns any found session" do
      expect(subject).to eql(found_session)
    end

  end

  describe "#find_or_create" do

    let(:session_id) { "some session id" }

    let(:found_session) { instance_double(HttpStub::Server::Session::Session) }

    subject { session_registry.find_or_create(session_id, logger) }

    before(:example) { allow(underlying_session_registry).to receive(:find).and_return(found_session) }

    context "when an id is provided" do

      it "attempts to find a session with the provided id in the underlying simple registry" do
        expect(underlying_session_registry).to receive(:find).with(session_id, logger)

        subject
      end

      context "and a session is not found" do

        let(:found_session) { nil }

        before(:example) { allow(underlying_session_registry).to receive(:add) }

        it "creates a session with the provided id" do
          expect(HttpStub::Server::Session::Session).to receive(:new).with(session_id, anything, anything)

          subject
        end

      end

    end

    context "when an id is not provided" do

      let(:session_id) { nil }

      it "attempts to find a session with the default id defined in the session configuration" do
        expect(underlying_session_registry).to receive(:find).with(default_session_id, logger)

        subject
      end

      context "and a session is not found" do

        let(:found_session) { nil }

        before(:example) { allow(underlying_session_registry).to receive(:add) }

        it "creates a session with the default session id" do
          expect(HttpStub::Server::Session::Session).to receive(:new).with(default_session_id, anything, anything)

          subject
        end

      end

    end

    context "when a session is found" do

      let(:found_session) { instance_double(HttpStub::Server::Session::Session) }

      it "returns the found session" do
        expect(subject).to eql(found_session)
      end

      it "does not add a session to the underlying simple registry" do
        expect(underlying_session_registry).to_not receive(:add)

        subject
      end

    end

    context "when a session is not found" do

      let(:found_session)   { nil }
      let(:created_session) { instance_double(HttpStub::Server::Session::Session) }

      before(:example) do
        allow(HttpStub::Server::Session::Session).to receive(:new).and_return(created_session)
        allow(underlying_session_registry).to receive(:add)
      end

      it "creates a session with the provided scenario registry" do
        expect(HttpStub::Server::Session::Session).to receive(:new).with(anything, scenario_registry, anything)

        subject
      end

      it "creates a session with the provided memory session" do
        expect(HttpStub::Server::Session::Session).to receive(:new).with(anything, anything, memory_session)

        subject
      end

      it "adds the created session to the underlying simple registry" do
        expect(underlying_session_registry).to receive(:add).with(created_session, logger)

        subject
      end

      it "returns the created session" do
        expect(subject).to eql(created_session)
      end

    end

  end

  describe "#all" do

    let(:sessions) { (1..3).map { instance_double(HttpStub::Server::Session::Session) } }

    subject { session_registry.all }

    before(:example) { allow(underlying_session_registry).to receive(:all).and_return(sessions) }

    it "delegates to an underlying simple registry" do
      expect(underlying_session_registry).to receive(:all)

      subject
    end

    it "returns the result from the underlying simple registry" do
      expect(subject).to eql(sessions)
    end

  end

  describe "#delete" do

    let(:id) { SecureRandom.uuid }

    subject { session_registry.delete(id, logger) }

    it "delegates to the underlying simple registry" do
      expect(underlying_session_registry).to receive(:delete).with(id, logger)

      subject
    end

  end

  describe "#clear" do

    subject { session_registry.clear(logger) }

    before(:example) do
      allow(memory_session).to receive(:clear)
      allow(underlying_session_registry).to receive(:replace)
    end

    it "clears the memory session" do
      expect(memory_session).to receive(:clear).with(logger)

      subject
    end

    it "replaces all sessions in the underlying simple registry with the memory session" do
      expect(underlying_session_registry).to receive(:replace).with([ memory_session ], logger)

      subject
    end

  end

end
