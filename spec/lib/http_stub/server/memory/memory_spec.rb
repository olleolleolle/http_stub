describe HttpStub::Server::Memory::Memory do

  let(:session_configuration) { instance_double(HttpStub::Server::Session::Configuration) }

  let(:memory_session)    { instance_double(HttpStub::Server::Session::Session) }
  let(:scenario_registry) { instance_double(HttpStub::Server::Registry) }
  let(:session_registry)  { instance_double(HttpStub::Server::Session::Registry) }

  let(:memory) { described_class.new(session_configuration) }

  before(:example) do
    allow(HttpStub::Server::Session::Session).to receive(:new).and_return(memory_session)
    allow(HttpStub::Server::Registry).to receive(:new).and_return(scenario_registry)
    allow(HttpStub::Server::Session::Registry).to receive(:new).and_return(session_registry)
  end

  it "creates a simple scenario registry" do
    expect(HttpStub::Server::Registry).to receive(:new).with("scenario")

    memory
  end

  it "creates a memory session" do
    expect(HttpStub::Server::Session::Session).to(
      receive(:new).with(HttpStub::Server::Session::MEMORY_SESSION_ID, anything, anything)
    )

    memory
  end

  it "creates a memory session containing the scenario registry" do
    expect(HttpStub::Server::Session::Session).to receive(:new).with(anything, scenario_registry, anything)

    memory
  end

  it "creates a memory session containing an empty memory session" do
    expect(HttpStub::Server::Session::Session).to(
      receive(:new).with(anything, anything, HttpStub::Server::Session::Empty)
    )

    memory
  end

  it "creates a session registry containing the session configuration" do
    expect(HttpStub::Server::Session::Registry).to receive(:new).with(session_configuration, anything, anything)

    memory
  end

  it "creates a session registry containing the scenario registry" do
    expect(HttpStub::Server::Session::Registry).to receive(:new).with(anything, scenario_registry, anything)

    memory
  end

  it "creates a session registry initalised with the memory session" do
    expect(HttpStub::Server::Session::Registry).to receive(:new).with(anything, anything, memory_session)

    memory
  end

  describe "#scenarios" do

    subject { memory.scenarios }

    it "returns the servers scenario registry" do
      expect(subject).to eql(scenario_registry)
    end

  end

  describe "#sessions" do

    subject { memory.sessions }

    it "returns the servers session registry" do
      expect(subject).to eql(session_registry)
    end

  end

  describe "#stubs" do

    let(:stubs) { (1..3).map { instance_double(HttpStub::Server::Stub::Stub) } }

    subject { memory.stubs }

    before(:example) { allow(memory_session).to receive(:stubs).and_return(stubs) }

    it "returns the stubs within the memory session" do
      expect(subject).to eql(stubs)
    end

  end

  describe "#reset" do

    let(:logger) { instance_double(Logger) }

    subject { memory.reset(logger) }

    before(:example) do
      allow(scenario_registry).to receive(:clear)
      allow(session_registry).to receive(:clear)
    end

    it "clears the servers scenarios" do
      expect(scenario_registry).to receive(:clear).with(logger)

      subject
    end

    it "clears the servers sessions" do
      expect(session_registry).to receive(:clear).with(logger)

      subject
    end

  end

end
