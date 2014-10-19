describe HttpStub::Configurer::Server::Facade do

  let(:configurer)    { double(HttpStub::Configurer) }
  let(:state_manager) { instance_double(HttpStub::Configurer::Server::StateManager) }

  let(:facade) { HttpStub::Configurer::Server::Facade.new(configurer) }

  before(:example) { allow(HttpStub::Configurer::Server::StateManager).to receive(:new).and_return(state_manager) }

  describe "#stub_response" do

    let(:stub_uri) { "/some/stub/uri" }
    let(:request)  { instance_double(HttpStub::Configurer::Request::Stub, stub_uri: stub_uri) }

    subject { facade.stub_response(request) }

    before(:example) { allow(state_manager).to receive(:add) }

    it "adds the stub request to the server state" do
      expect(state_manager).to receive(:add).with(hash_including(request: request))

      subject
    end

    it "describes the stub via its stub uri" do
      expect(state_manager).to receive(:add).with(hash_including(description: "stubbing '#{stub_uri}'"))

      subject
    end

    it "declares the request is resetable" do
      expect(state_manager).to receive(:add).with(hash_including(resetable: true))

      subject
    end

  end

  describe "#stub_activator" do

    let(:activation_uri) { "/some/activation/uri" }
    let(:request) { instance_double(HttpStub::Configurer::Request::StubActivator, activation_uri: activation_uri) }

    subject { facade.stub_activator(request) }

    before(:example) { allow(state_manager).to receive(:add) }

    it "adds the stub request to the server state" do
      expect(state_manager).to receive(:add).with(hash_including(request: request))

      subject
    end

    it "describes the stub via its activation uri" do
      expect(state_manager).to(
        receive(:add).with(hash_including(description: "registering activator '#{activation_uri}'"))
      )

      subject
    end

    it "does not declare that the request is resetable" do
      expect(state_manager).to receive(:add).with(hash_excluding(:resetable))

      subject
    end

  end

  describe "#activate" do

    let(:uri)     { "/some/activation/uri" }
    let(:request) { instance_double(Net::HTTP::Get) }

    subject { facade.activate(uri) }

    before(:example) do
      allow(Net::HTTP::Get).to receive(:new).and_return(request)
      allow(state_manager).to receive(:add)
    end

    it "creates a GET request for the uri" do
      expect(Net::HTTP::Get).to receive(:new).with(uri).and_return(request)

      subject
    end

    it "adds the GET request to the server state" do
      expect(state_manager).to receive(:add).with(hash_including(request: request))

      subject
    end

    it "describes the activation request via the provided uri" do
      expect(state_manager).to receive(:add).with(hash_including(description: "activating '#{uri}'"))

      subject
    end

    it "declares the request is resetable" do
      expect(state_manager).to receive(:add).with(hash_including(resetable: true))

      subject
    end

  end

  describe "#remember_state" do

    it "delegates to the state manager" do
      expect(state_manager).to receive(:remember)

      facade.remember_state
    end

  end

  describe "#flush_pending_state" do

    it "delegates to the state manager" do
      expect(state_manager).to receive(:flush_pending_state)

      facade.flush_pending_state
    end

  end

  describe "#recall_state" do

    before(:example) do
      allow(facade).to receive(:clear_stubs)
      allow(state_manager).to receive(:recall)
    end

    it "clears the servers stubs" do
      expect(facade).to receive(:clear_stubs)

      facade.recall_state
    end

    it "informs the state manager to replay the initial state" do
      expect(state_manager).to receive(:recall)

      facade.recall_state
    end

  end

  describe "#clear_stubs" do

    let(:request) { instance_double(Net::HTTP::Delete) }

    subject { facade.clear_stubs }

    before(:example) do
      allow(Net::HTTP::Delete).to receive(:new).and_return(request)
      allow(state_manager).to receive(:add)
    end

    it "creates a DELETE request for the /stubs endpoint" do
      expect(Net::HTTP::Delete).to receive(:new).with("/stubs").and_return(request)

      subject
    end

    it "adds the DELETE request to the server state" do
      expect(state_manager).to receive(:add).with(hash_including(request: request))

      subject
    end

    it "describes the request as clearing the server stubs" do
      expect(state_manager).to receive(:add).with(hash_including(description: "clearing stubs"))

      subject
    end

  end

  describe "#clear_activators" do

    let(:request) { instance_double(Net::HTTP::Delete) }

    subject { facade.clear_activators }

    before(:example) do
      allow(Net::HTTP::Delete).to receive(:new).and_return(request)
      allow(state_manager).to receive(:add)
    end

    it "creates a DELETE request for the /stubs/activators endpoint" do
      expect(Net::HTTP::Delete).to receive(:new).with("/stubs/activators").and_return(request)

      subject
    end

    it "adds the DELETE request to the server state" do
      expect(state_manager).to receive(:add).with(hash_including(request: request))

      subject
    end

    it "describes the request as clearing the server stub activators" do
      expect(state_manager).to receive(:add).with(hash_including(description: "clearing activators"))

      subject
    end

  end

end
