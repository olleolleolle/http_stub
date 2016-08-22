describe HttpStub::Server::Stub::Registry do

  let(:underlying_stub_registry) { instance_double(HttpStub::Server::Registry) }

  let(:logger) { instance_double(Logger) }

  let(:stub_registry) { HttpStub::Server::Stub::Registry.new }

  before(:example) { allow(HttpStub::Server::Registry).to receive(:new).and_return(underlying_stub_registry) }

  describe "#add" do

    let(:stub) { instance_double(HttpStub::Server::Stub::Stub) }

    subject { stub_registry.add(stub, logger) }

    it "delegates to an underlying simple registry" do
      expect(underlying_stub_registry).to receive(:add).with(stub, logger)

      subject
    end

  end

  describe "#concat" do

    let(:stubs)  { (1..3).map { instance_double(HttpStub::Server::Stub::Stub) } }

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

    it "delegates to an underlying simple registry" do
      expect(underlying_stub_registry).to receive(:all)

      subject
    end

    it "returns the result from the underlying registry" do
      allow(underlying_stub_registry).to receive(:all).and_return(stubs)

      expect(subject).to eql(stubs)
    end

  end

  describe "#recall" do

    subject { stub_registry.recall }

    context "when the state of the registry has been remembered" do

      let(:last_stub_remembered) { instance_double(HttpStub::Server::Stub::Stub) }

      before(:example) do
        allow(underlying_stub_registry).to receive(:last).and_return(last_stub_remembered)
        stub_registry.remember
      end

      it "causes the underlying registry to rollback to the last stub added before the state was remembered" do
        expect(underlying_stub_registry).to receive(:rollback_to).with(last_stub_remembered)

        subject
      end

    end

    context "when the state of the registry has not been remembered" do

      it "does not rollback the underlying registry" do
        expect(underlying_stub_registry).to_not receive(:rollback_to)

        subject
      end

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
