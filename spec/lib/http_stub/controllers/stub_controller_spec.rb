describe HttpStub::Controllers::StubController do

  let(:request_body) { "Some request body" }
  let(:stub_options) { double("StubOptions") }
  let(:request) { double("HttpRequest", body: double("RequestBody", read: request_body)) }
  let(:response) { double(HttpStub::Response) }
  let(:the_stub) { double(HttpStub::Models::Stub, response: response) }
  let(:registry) { double(HttpStub::Models::Registry).as_null_object }
  let(:controller) { HttpStub::Controllers::StubController.new(registry) }

  before(:each) { JSON.stub!(:parse).and_return(stub_options) }

  describe "#register" do

    before(:each) do
      HttpStub::Models::Stub.stub!(:new).and_return(the_stub)
    end

    it "should parse an options hash from the JSON request body" do
      JSON.should_receive(:parse).with(request_body).and_return(stub_options)

      controller.register(request)
    end

    it "should create a stub from the parsed options" do
      HttpStub::Models::Stub.should_receive(:new).with(stub_options).and_return(the_stub)

      controller.register(request)
    end

    it "should add the stub to the stub registry" do
      registry.should_receive(:add).with(the_stub, request)

      controller.register(request)
    end

    it "should return a success response" do
      controller.register(request).should eql(HttpStub::Response::SUCCESS)
    end

  end

  describe "#replay" do

    describe "when a stub has been registered that should be replayed for the request" do

      before(:each) do
        registry.stub!(:find_for).with(request).and_return(the_stub)
      end

      it "should return the stubs response" do
        the_stub.should_receive(:response).and_return(response)

        controller.replay(request).should eql(response)
      end

    end

    describe "when no stub should be replayed for the request" do

      before(:each) do
        registry.stub!(:find_for).with(request).and_return(nil)
      end

      it "should return an empty response" do
        controller.replay(request).should eql(HttpStub::Response::EMPTY)
      end

    end

  end

  describe "#clear" do

    it "should clear the stub registry" do
      registry.should_receive(:clear).with(request)

      controller.clear(request)
    end

  end

end
