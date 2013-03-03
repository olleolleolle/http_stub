describe HttpStub::Controllers::StubActivatorController do

  let(:request_body) { "Some request body" }
  let(:request) { double("HttpRequest", body: double("RequestBody", read: request_body)) }
  let(:stub_activator_options) { double("StubActivatorOptions") }
  let(:the_stub) { double(HttpStub::Models::Stub) }
  let(:stub_activator) { double(HttpStub::Models::StubActivator, the_stub: the_stub) }
  let(:stub_activator_registry) { double("HttpStub::Models::StubActivatorRegistry").as_null_object }
  let(:stub_registry) { double("HttpStub::Models::StubRegistry").as_null_object }
  let(:controller) { HttpStub::Controllers::StubActivatorController.new(stub_activator_registry, stub_registry) }

  before(:each) { JSON.stub!(:parse).and_return(stub_activator_options) }

  describe "#register" do

    before(:each) do
      HttpStub::Models::StubActivator.stub!(:new).and_return(stub_activator)
    end

    it "should parse an options hash from the JSON request body" do
      JSON.should_receive(:parse).with(request_body).and_return(stub_activator_options)

      controller.register(request)
    end

    it "should create a stub activator from the parsed options" do
      HttpStub::Models::StubActivator.should_receive(:new).with(stub_activator_options).and_return(stub_activator)

      controller.register(request)
    end

    it "should add the created activator to the activator registry" do
      stub_activator_registry.should_receive(:add).with(stub_activator, request)

      controller.register(request)
    end

    it "should return a success response" do
      controller.register(request).should eql(HttpStub::Response::SUCCESS)
    end

  end

  describe "#activate" do

    describe "when a stub activator has been registered that is activated by the request" do

      before(:each) do
        stub_activator_registry.stub!(:find_for).with(request).and_return(stub_activator)
      end

      it "should add the activators stub to the stub registry" do
        stub_registry.should_receive(:add).with(the_stub, request)

        controller.activate(request)
      end

      it "should return a success response" do
        controller.activate(request).should eql(HttpStub::Response::SUCCESS)
      end

    end

    describe "when no stub activator is activated by the request" do

      before(:each) do
        stub_activator_registry.stub!(:find_for).with(request).and_return(nil)
      end

      it "should not add a stub to the registry" do
        stub_registry.should_not_receive(:add)

        controller.activate(request)
      end

      it "should return an empty response" do
        controller.activate(request).should eql(HttpStub::Response::EMPTY)
      end

    end

  end

  describe "#clear" do

    it "should clear the activator registry" do
      stub_activator_registry.should_receive(:clear).with(request)

      controller.clear(request)
    end

  end

end
