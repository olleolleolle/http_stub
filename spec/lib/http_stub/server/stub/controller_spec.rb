describe HttpStub::Server::Stub::Controller do

  let(:request)  { instance_double(HttpStub::Server::Request) }
  let(:logger)   { instance_double(Logger) }
  let(:payload)  { HttpStub::StubFixture.new.server_payload }
  let(:response) { instance_double(HttpStub::Server::Stub::Response::Base) }
  let(:stub_uri) { "/some/stub/uri" }
  let(:the_stub) { instance_double(HttpStub::Server::Stub::Stub, response: response, stub_uri: stub_uri) }
  let(:registry) { instance_double(HttpStub::Server::Stub::Registry).as_null_object }

  let(:controller) { HttpStub::Server::Stub::Controller.new(registry) }

  before(:example) do
    allow(HttpStub::Server::Stub::Parser).to receive(:parse).and_return(payload)
    allow(HttpStub::Server::Stub).to receive(:create).and_return(the_stub)
  end

  describe "#register" do

    subject { controller.register(request, logger) }

    it "parses the payload from the request" do
      expect(HttpStub::Server::Stub::Parser).to receive(:parse).with(request).and_return(payload)

      subject
    end

    it "creates a stub with the parsed payload" do
      expect(HttpStub::Server::Stub).to receive(:create).with(payload).and_return(the_stub)

      subject
    end

    it "adds the stub to the stub registry" do
      expect(registry).to receive(:add).with(the_stub, logger)

      subject
    end

    it "creates a success response with a location header containing the stubs uri" do
      expect(HttpStub::Server::Response).to receive(:success).with("location" => stub_uri)

      subject
    end

    it "returns the success response" do
      response = double("HttpStub::Server::Response")
      allow(HttpStub::Server::Response).to receive(:success).and_return(response)

      expect(subject).to eql(response)
    end

  end

  describe "#replay" do

    subject { controller.replay(request, logger) }

    describe "when a stub has been registered that should be replayed for the request" do

      before(:example) { allow(registry).to receive(:find).with(request, logger).and_return(the_stub) }

      it "returns the stubs response" do
        expect(the_stub).to receive(:response).and_return(response)

        expect(subject).to eql(response)
      end

    end

    describe "when no stub should be replayed for the request" do

      before(:example) { allow(registry).to receive(:find).with(request, logger).and_return(nil) }

      it "returns an empty response" do
        expect(subject).to eql(HttpStub::Server::Response::EMPTY)
      end

    end

  end

  describe "#clear" do

    subject { controller.clear(logger) }

    it "clears the stub registry" do
      expect(registry).to receive(:clear).with(logger)

      subject
    end

  end

end
