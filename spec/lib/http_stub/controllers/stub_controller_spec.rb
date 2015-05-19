describe HttpStub::Controllers::StubController do

  let(:request)  { double("HttpRequest") }
  let(:response) { double(HttpStub::Models::Response) }
  let(:the_stub) { double(HttpStub::Models::Stub, response: response) }
  let(:registry) { double(HttpStub::Models::Registry).as_null_object }

  let(:controller) { HttpStub::Controllers::StubController.new(registry) }

  before(:example) { allow(HttpStub::Models::StubFactory).to receive(:create).and_return(the_stub) }

  describe "#register" do

    subject { controller.register(request) }

    it "creates a stub from the provided request via the factory" do
      expect(HttpStub::Models::StubFactory).to receive(:create).with(request).and_return(the_stub)

      subject
    end

    it "adds the stub to the stub registry" do
      expect(registry).to receive(:add).with(the_stub, request)

      subject
    end

    it "returns a success response" do
      expect(subject).to eql(HttpStub::Models::Response::SUCCESS)
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
