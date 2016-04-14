describe HttpStub::Server::Stub::Registry do

  let(:match_result_registry)    { instance_double(HttpStub::Server::Registry) }
  let(:underlying_stub_registry) { instance_double(HttpStub::Server::Registry) }

  let(:logger) { instance_double(Logger) }

  let(:stub_registry) { HttpStub::Server::Stub::Registry.new(match_result_registry) }

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
    let(:match_result) { instance_double(HttpStub::Server::Stub::Match::Result) }

    subject { stub_registry.match(request, logger) }

    before(:example) do
      allow(underlying_stub_registry).to receive(:find).and_return(found_stub)
      allow(HttpStub::Server::Stub::Match::Result).to receive(:new).and_return(match_result)
      allow(match_result_registry).to receive(:add)
    end

    it "finds a matching stub in the underlying simple registry based on the request" do
      expect(underlying_stub_registry).to receive(:find).with(request, logger)

      subject
    end

    context "when a stub is found" do

      let(:found_stub) { stub }

      it "creates a match containing the request and the stub" do
        expect(HttpStub::Server::Stub::Match::Result).to receive(:new).with(request, stub)

        subject
      end

      it "adds the match result to the match result registry" do
        expect(match_result_registry).to receive(:add).with(match_result, logger)

        subject
      end

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

      it "creates a match result with a nil stub" do
        expect(HttpStub::Server::Stub::Match::Result).to receive(:new).with(request, nil)

        subject
      end

      it "adds the match result to the match result registry" do
        expect(match_result_registry).to receive(:add).with(match_result, logger)

        subject
      end

      it "returns the result from the underlying registry" do
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

    before(:example) do
      allow(underlying_stub_registry).to receive(:clear)
      allow(match_result_registry).to receive(:clear)
    end

    it "clears the underlying simple registry" do
      expect(underlying_stub_registry).to receive(:clear).with(logger)

      subject
    end

    it "clears the match result registry" do
      expect(match_result_registry).to receive(:clear).with(logger)

      subject
    end

  end

end
