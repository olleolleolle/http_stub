describe HttpStub::Models::StubRegistry do

  let(:registry)      { instance_double(HttpStub::Models::Registry) }

  let(:stub_registry) { HttpStub::Models::StubRegistry.new }

  before(:example) { allow(HttpStub::Models::Registry).to receive(:new).and_return(registry) }

  describe "#add" do

    let(:stub)    { instance_double(HttpStub::Models::Stub) }
    let(:request) { double("HttpRequest") }

    it "delegates to an underlying simple registry" do
      expect(registry).to receive(:add).with(stub, request)

      stub_registry.add(stub, request)
    end

  end

  describe "#find_for" do

    let(:request) { double("HttpRequest") }

    subject { stub_registry.find_for(request) }

    it "delegates to an underlying simple registry" do
      expect(registry).to receive(:find_for).with(request)

      subject
    end

    context "when a stub is found" do

      let(:triggers) { instance_double(HttpStub::Models::StubTriggers) }
      let(:stub)     { instance_double(HttpStub::Models::Stub, triggers: triggers) }

      before(:example) { allow(registry).to receive(:find_for).and_return(stub) }

      it "should add the stubs triggers to the registry" do
        expect(triggers).to receive(:add_to).with(stub_registry, request)

        subject
      end

      it "returns the stub found in the underlying registry" do
        allow(triggers).to receive(:add_to)

        expect(subject).to eql(stub)
      end

    end

    context "when a stub is not found" do

      before(:example) { allow(registry).to receive(:find_for).and_return(nil) }

      it "returns the result from the underlying registry" do
        expect(subject).to eql(nil)
      end

    end

  end

  describe "#remember" do

    it "copies the underlying registry" do
      expect(registry).to receive(:copy)

      stub_registry.remember
    end

  end

  describe "#recall" do

    subject { stub_registry.recall }

    context "when the state of the registry has been remembered" do

      let(:remembered_registry)         { instance_double(HttpStub::Models::Registry) }
      let(:copy_of_remembered_registry) { instance_double(HttpStub::Models::Registry) }

      before(:example) do
        allow(registry).to receive(:copy).and_return(remembered_registry)
        allow(remembered_registry).to receive(:copy).and_return(copy_of_remembered_registry)
        stub_registry.remember
      end

      it "copies the remembered registry to ensure subsequent recalls recall the same stubs" do
        expect(remembered_registry).to receive(:copy)

        subject
      end

      it "causes subsequent method calls to delegate to the copy" do
        subject

        expect(copy_of_remembered_registry).to receive(:all)
        stub_registry.all
      end

    end

    context "when the state of the registry has not been remembered" do

      it "does not effect subsequent method calls" do
        subject

        expect(registry).to receive(:all)
        stub_registry.all
      end

    end

  end

  describe "#all" do

    let(:stubs) { (1..3).map { instance_double(HttpStub::Models::Stub) } }

    subject { stub_registry.all }

    it "delegates to an underlying simple registry" do
      expect(registry).to receive(:all)

      subject
    end

    it "returns the result from the underlying registry" do
      allow(registry).to receive(:all).and_return(stubs)

      expect(subject).to eql(stubs)
    end

  end

  describe "#clear" do

    let(:request) { double("HttpRequest") }

    it "delegates to an underlying simple registry" do
      expect(registry).to receive(:clear).with(request)

      stub_registry.clear(request)
    end

  end

end
