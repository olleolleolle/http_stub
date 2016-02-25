describe HttpStub::Server::Stub::Registry do

  let(:match_registry)           { instance_double(HttpStub::Server::Registry) }
  let(:underlying_stub_registry) { instance_double(HttpStub::Server::Registry) }

  let(:logger)                   { instance_double(Logger) }

  let(:stub_registry) { HttpStub::Server::Stub::Registry.new(match_registry) }

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

    let(:triggers) { instance_double(HttpStub::Server::Stub::Triggers, add_to: nil) }
    let(:stub)     { instance_double(HttpStub::Server::Stub::Stub, triggers: triggers) }

    subject { stub_registry.find(criteria, logger) }

    shared_examples_for "an approach to finding a stub in the registry" do

      it "delegates to an underlying simple registry to find based on the criteria" do
        expect(underlying_stub_registry).to receive(:find).with(criteria, logger)

        subject
      end

      context "when a stub is found" do

        before(:example) { allow(underlying_stub_registry).to receive(:find).and_return(stub) }

        it "returns the stub found in the underlying stub registry" do
          expect(subject).to eql(stub)
        end

      end

      context "when a stub is not found" do

        before(:example) { allow(underlying_stub_registry).to receive(:find).and_return(nil) }

        it "returns the result from the underlying registry" do
          expect(subject).to eql(nil)
        end

      end

    end

    context "when a request is provided" do

      let(:request)  { HttpStub::Server::RequestFixture.create }
      let(:criteria) { request }

      let(:stub_match) { instance_double(HttpStub::Server::Stub::Match::Match) }

      before(:example) do
        allow(HttpStub::Server::Stub::Match::Match).to receive(:new).and_return(stub_match)
        allow(match_registry).to receive(:add)
      end

      it_behaves_like "an approach to finding a stub in the registry"

      context "when a stub is found" do

        before(:example) { allow(underlying_stub_registry).to receive(:find).and_return(stub) }

        it "creates a match containing the stub and request" do
          expect(HttpStub::Server::Stub::Match::Match).to receive(:new).with(stub, request)

          subject
        end

        it "adds the match to the match registry" do
          expect(match_registry).to receive(:add).with(stub_match, logger)

          subject
        end

        it "adds the stubs triggers to the underlying stub registry" do
          expect(triggers).to receive(:add_to).with(stub_registry, logger)

          subject
        end

      end

      context "when a stub is not found" do

        before(:example) { allow(underlying_stub_registry).to receive(:find).and_return(nil) }

        it "creates a match with a nil stub" do
          expect(HttpStub::Server::Stub::Match::Match).to receive(:new).with(nil, request)

          subject
        end

        it "adds the match to the match registry" do
          expect(match_registry).to receive(:add).with(stub_match, logger)

          subject
        end

      end

    end

    context "when an id is provided" do

      let(:id)       { SecureRandom.uuid }
      let(:criteria) { id }

      before(:example) { allow(underlying_stub_registry).to receive(:find).and_return(nil) }

      it_behaves_like "an approach to finding a stub in the registry"

      it "does not add a match to the match registry" do
        expect(match_registry).to_not receive(:add)

        subject
      end

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

  describe "#clear" do

    subject { stub_registry.clear(logger) }

    before(:example) do
      allow(underlying_stub_registry).to receive(:clear)
      allow(match_registry).to receive(:clear)
    end

    it "clears the underlying simple registry" do
      expect(underlying_stub_registry).to receive(:clear).with(logger)

      subject
    end

    it "clears the match registry" do
      expect(match_registry).to receive(:clear).with(logger)

      subject
    end

  end

end
