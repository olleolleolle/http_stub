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

    subject { stub_registry.find(id, logger) }

    it "delegates to an underlying simple registry" do
      expect(underlying_stub_registry).to receive(:find).with(id, logger)

      subject
    end

  end

  describe "#match" do

    let(:request)  { HttpStub::Server::RequestFixture.create }

    let(:triggers)     { instance_double(HttpStub::Server::Stub::Triggers, add_to: nil) }
    let(:stub)         { instance_double(HttpStub::Server::Stub::Stub, triggers: triggers) }
    let(:found_stub)   { nil }

    subject { stub_registry.match(request, logger) }

    before(:example) { allow(underlying_stub_registry).to receive(:find).and_return(found_stub) }

    it "finds a matching stub in the underlying simple registry based on the request" do
      expect(underlying_stub_registry).to receive(:find).with(request, logger)

      subject
    end

    context "when a stub is found" do

      let(:found_stub) { stub }

      it "adds the stubs triggers to the underlying stub registry" do
        expect(triggers).to receive(:add_to).with(stub_registry, logger)

        subject
      end

      it "returns the stub found in the underlying stub registry" do
        expect(subject).to eql(stub)
      end

    end

    context "when a stub is not found" do

      let(:found_stub) { nil }

      it "returns nil" do
        expect(subject).to eql(nil)
      end

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
