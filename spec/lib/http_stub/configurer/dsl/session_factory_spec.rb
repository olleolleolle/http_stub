describe HttpStub::Configurer::DSL::SessionFactory do

  let(:server_facade)         { instance_double(HttpStub::Configurer::Server::Facade) }
  let(:default_stub_template) { instance_double(HttpStub::Configurer::DSL::StubBuilderTemplate) }

  let(:session) { instance_double(HttpStub::Configurer::DSL::Session) }

  let(:session_factory) { described_class.new(server_facade, default_stub_template) }

  describe "#create" do

    let(:id) { "some_session_id" }

    subject { create_session }

    it "creates a session with the provided ID" do
      expect(HttpStub::Configurer::DSL::Session).to receive(:new).with(id, anything, anything)

      subject
    end

    it "creates a session uses the stubs server facade" do
      expect(HttpStub::Configurer::DSL::Session).to receive(:new).with(anything, server_facade, anything)

      subject
    end

    it "creates a session uses the stubs default stub template" do
      expect(HttpStub::Configurer::DSL::Session).to receive(:new).with(anything, anything, default_stub_template)

      subject
    end

    it "returns the created session" do
      allow(HttpStub::Configurer::DSL::Session).to receive(:new).and_return(session)

      expect(subject).to eql(session)

    end

    context "when a session has been created" do

      before(:example) do
        allow(HttpStub::Configurer::DSL::Session).to receive(:new).and_return(session).once

        create_session
      end

      it "returns the same session when a session with the same ID is created" do
        expect(subject).to be(session)
      end

    end

    def create_session
      session_factory.create(id)
    end

  end

  describe "#memory" do

    subject { session_factory.memory }

    it "creates a session whose ID is an internal memory identifier" do
      expect(session_factory).to receive(:create).with("http_stub_memory")

      subject
    end

    it "returns the created session" do
      allow(session_factory).to receive(:create).and_return(session)

      expect(subject).to eql(session)
    end

  end

  describe "#transactional" do

    subject { session_factory.transactional }

    it "creates a session whose ID is an internal transactional space identifier" do
      expect(session_factory).to receive(:create).with("http_stub_transactional")

      subject
    end

    it "returns the created session" do
      allow(session_factory).to receive(:create).and_return(session)

      expect(subject).to eql(session)
    end

  end

end
