describe HttpStub::Server::Stub::Registry do

  let(:stubs_in_memory) { (1..3).map { instance_double(HttpStub::Server::Stub::Stub) } }
  let(:memory_session)  { instance_double(HttpStub::Server::Session::Session, stubs: stubs_in_memory) }

  let(:underlying_stub_registry) { instance_double(HttpStub::Server::Registry) }
  let(:logger)                   { instance_double(Logger) }

  let(:stub_registry) { described_class.new(memory_session) }

  before(:example) { allow(HttpStub::Server::Registry).to receive(:new).and_return(underlying_stub_registry) }

  it "uses an underlying simple registry that is initialised with the memory sessions stubs" do
    expect(HttpStub::Server::Registry).to receive(:new).with("stub", stubs_in_memory)

    stub_registry
  end

  describe "#add" do

    let(:stub) { instance_double(HttpStub::Server::Stub::Stub) }

    subject { stub_registry.add(stub, logger) }

    it "delegates to an underlying simple registry" do
      expect(underlying_stub_registry).to receive(:add).with(stub, logger)

      subject
    end

  end

  describe "#concat" do

    let(:stubs) { (1..3).map { instance_double(HttpStub::Server::Stub::Stub) } }

    subject { stub_registry.concat(stubs, logger) }

    it "delegates to an underlying simple registry" do
      expect(underlying_stub_registry).to receive(:concat).with(stubs, logger)

      subject
    end

  end

  describe "#find" do

    let(:id) { SecureRandom.uuid }

    let(:found_stub) { instance_double(HttpStub::Server::Stub::Stub) }

    subject { stub_registry.find(id, logger) }

    before(:example) { allow(underlying_stub_registry).to receive(:find).and_return(found_stub) }

    it "delegates to an underlying simple registry" do
      expect(underlying_stub_registry).to receive(:find).with(id, logger)

      subject
    end

    it "returns any found stub" do
      expect(subject).to eql(found_stub)
    end

  end

  describe "#match" do

    let(:request) { instance_double(HttpStub::Server::Request::Request) }

    let(:matched_stub) { instance_double(HttpStub::Server::Stub::Stub) }

    subject { stub_registry.find(request, logger) }

    before(:example) { allow(underlying_stub_registry).to receive(:find).and_return(matched_stub) }

    it "finds a matching stub in an underlying simple registry" do
      expect(underlying_stub_registry).to receive(:find).with(request, logger)

      subject
    end

    it "returns any found stub" do
      expect(subject).to eql(matched_stub)
    end

  end

  describe "#all" do

    let(:stubs) { (1..3).map { instance_double(HttpStub::Server::Stub::Stub) } }

    subject { stub_registry.all }

    before(:example) { allow(underlying_stub_registry).to receive(:all).and_return(stubs) }

    it "delegates to an underlying simple registry" do
      expect(underlying_stub_registry).to receive(:all)

      subject
    end

    it "returns the result from the underlying registry" do
      expect(subject).to eql(stubs)
    end

  end

  describe "#reset" do

    subject { stub_registry.reset(logger) }

    before(:example) { allow(underlying_stub_registry).to receive(:replace) }

    it "retrieves the stubs in the memory session" do
      expect(memory_session).to receive(:stubs)

      subject
    end

    it "replaces the stubs in the underlying registry with those in the memory session" do
      expect(underlying_stub_registry).to receive(:replace).with(stubs_in_memory, logger)

      subject
    end

  end

  describe "#clear" do

    subject { stub_registry.clear(logger) }

    it "delegates to the underlying simple registry" do
      expect(underlying_stub_registry).to receive(:clear).with(logger)

      subject
    end

  end

end
