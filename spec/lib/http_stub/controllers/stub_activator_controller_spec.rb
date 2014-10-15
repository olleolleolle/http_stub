describe HttpStub::Controllers::StubActivatorController do

  let(:request_body) { "Some request body" }
  let(:request) { double("HttpRequest", body: double("RequestBody", read: request_body)) }
  let(:stub_activator_options) { double("StubActivatorOptions") }
  let(:the_stub) { double(HttpStub::Models::Stub) }
  let(:stub_activator) { double(HttpStub::Models::StubActivator, the_stub: the_stub) }
  let(:stub_activator_registry) { double("HttpStub::Models::StubActivatorRegistry").as_null_object }
  let(:stub_registry) { double("HttpStub::Models::StubRegistry").as_null_object }
  let(:controller) { HttpStub::Controllers::StubActivatorController.new(stub_activator_registry, stub_registry) }

  before(:example) { allow(JSON).to receive(:parse).and_return(stub_activator_options) }

  describe "#register" do

    before(:example) do
      allow(HttpStub::Models::StubActivator).to receive(:new).and_return(stub_activator)
    end

    it "parses an options hash from the JSON request body" do
      expect(JSON).to receive(:parse).with(request_body).and_return(stub_activator_options)

      controller.register(request)
    end

    it "creates a stub activator from the parsed options" do
      expect(HttpStub::Models::StubActivator).to receive(:new).with(stub_activator_options).and_return(stub_activator)

      controller.register(request)
    end

    it "adds the created activator to the activator registry" do
      expect(stub_activator_registry).to receive(:add).with(stub_activator, request)

      controller.register(request)
    end

    it "returns a success response" do
      expect(controller.register(request)).to eql(HttpStub::Models::Response::SUCCESS)
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
