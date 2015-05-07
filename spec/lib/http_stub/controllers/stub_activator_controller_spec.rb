describe HttpStub::Controllers::StubActivatorController do

  let(:request)                 { double("HttpRequest") }
  let(:the_stub)                { double(HttpStub::Models::Stub) }
  let(:stub_activator)          { double(HttpStub::Models::StubActivator, the_stub: the_stub) }
  let(:stub_activator_registry) { double("HttpStub::Models::StubActivatorRegistry").as_null_object }
  let(:stub_registry)           { double("HttpStub::Models::StubRegistry").as_null_object }

  let(:controller) { HttpStub::Controllers::StubActivatorController.new(stub_activator_registry, stub_registry) }

  before(:example) { allow(HttpStub::Models::StubActivator).to receive(:create_from).and_return(stub_activator) }

  describe "#register" do

    subject { controller.register(request) }

    it "creates a stub activator from the provided request" do
      expect(HttpStub::Models::StubActivator).to receive(:create_from).with(request).and_return(stub_activator)

      subject
    end

    it "adds the created activator to the activator registry with the provided request" do
      expect(stub_activator_registry).to receive(:add).with(stub_activator, request)

      subject
    end

    it "returns a success response" do
      expect(subject).to eql(HttpStub::Models::Response::SUCCESS)
    end

  end

  describe "#activate" do

    describe "when a stub activator has been registered that is activated by the request" do

      before(:example) do
        allow(stub_activator_registry).to receive(:find_for).with(request).and_return(stub_activator)
      end

      it "adds the activators stub to the stub registry" do
        expect(stub_registry).to receive(:add).with(the_stub, request)

        controller.activate(request)
      end

      it "returns a success response" do
        expect(controller.activate(request)).to eql(HttpStub::Models::Response::SUCCESS)
      end

    end

    describe "when no stub activator is activated by the request" do

      before(:example) do
        allow(stub_activator_registry).to receive(:find_for).with(request).and_return(nil)
      end

      it "does not add a stub to the registry" do
        expect(stub_registry).not_to receive(:add)

        controller.activate(request)
      end

      it "returns an empty response" do
        expect(controller.activate(request)).to eql(HttpStub::Models::Response::EMPTY)
      end

    end

  end

  describe "#clear" do

    it "clears the activator registry" do
      expect(stub_activator_registry).to receive(:clear).with(request)

      controller.clear(request)
    end

  end

end
