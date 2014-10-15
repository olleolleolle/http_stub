describe HttpStub::Controllers::StubController do

  let(:request_body) { "Some request body" }
  let(:stub_options) { double("StubOptions") }
  let(:request) { double("HttpRequest", body: double("RequestBody", read: request_body)) }
  let(:response) { double(HttpStub::Models::Response) }
  let(:the_stub) { double(HttpStub::Models::Stub, response: response) }
  let(:registry) { double(HttpStub::Models::Registry).as_null_object }
  let(:controller) { HttpStub::Controllers::StubController.new(registry) }

  before(:example) { allow(JSON).to receive(:parse).and_return(stub_options) }

  describe "#register" do

    before(:example) do
      allow(HttpStub::Models::Stub).to receive(:new).and_return(the_stub)
    end

    it "parses an options hash from the JSON request body" do
      expect(JSON).to receive(:parse).with(request_body).and_return(stub_options)

      controller.register(request)
    end

    it "creates a stub from the parsed options" do
      expect(HttpStub::Models::Stub).to receive(:new).with(stub_options).and_return(the_stub)

      controller.register(request)
    end

    it "adds the stub to the stub registry" do
      expect(registry).to receive(:add).with(the_stub, request)

      controller.register(request)
    end

    it "returns a success response" do
      expect(controller.register(request)).to eql(HttpStub::Models::Response::SUCCESS)
    end

  end

  describe "#replay" do

    describe "when a stub has been registered that should be replayed for the request" do

      before(:example) do
        allow(registry).to receive(:find_for).with(request).and_return(the_stub)
      end

      it "returns the stubs response" do
        expect(the_stub).to receive(:response).and_return(response)

        expect(controller.replay(request)).to eql(response)
      end

    end

    describe "when no stub should be replayed for the request" do

      before(:example) do
        allow(registry).to receive(:find_for).with(request).and_return(nil)
      end

      it "returns an empty response" do
        expect(controller.replay(request)).to eql(HttpStub::Models::Response::EMPTY)
      end

    end

  end

  describe "#clear" do

    it "clears the stub registry" do
      expect(registry).to receive(:clear).with(request)

      controller.clear(request)
    end

  end

end
