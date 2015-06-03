describe HttpStub::Server::Stub::Controller do

  let(:request)  { instance_double(Rack::Request) }
  let(:payload)  { HttpStub::StubFixture.new.server_payload }
  let(:response) { instance_double(HttpStub::Server::Stub::Response::Base) }
  let(:the_stub) { instance_double(HttpStub::Server::Stub::Instance, response: response) }
  let(:registry) { instance_double(HttpStub::Server::Stub::Registry).as_null_object }

  let(:controller) { HttpStub::Server::Stub::Controller.new(registry) }

  before(:example) do
    allow(HttpStub::Server::Stub::RequestParser).to receive(:parse).and_return(payload)
    allow(HttpStub::Server::Stub).to receive(:create).and_return(the_stub)
  end

  describe "#register" do

    subject { controller.register(request) }

    it "parses the payload from the request" do
      expect(HttpStub::Server::Stub::RequestParser).to receive(:parse).with(request).and_return(payload)

      subject
    end

    it "creates a stub with the parsed payload" do
      expect(HttpStub::Server::Stub).to receive(:create).with(payload).and_return(the_stub)

      subject
    end

    it "adds the stub to the stub registry" do
      expect(registry).to receive(:add).with(the_stub, request)

      subject
    end

    it "returns a success response" do
      expect(subject).to eql(HttpStub::Server::Response::SUCCESS)
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
        expect(controller.replay(request)).to eql(HttpStub::Server::Response::EMPTY)
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
