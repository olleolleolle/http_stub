describe HttpStub::Server::Stub::Controller do

  let(:request)  { instance_double(HttpStub::Server::Request::Request) }
  let(:logger)   { instance_double(Logger) }
  let(:payload)  { HttpStub::StubFixture.new.server_payload }
  let(:response) { instance_double(HttpStub::Server::Stub::Response::Base) }
  let(:stub_uri) { "/some/stub/uri" }
  let(:the_stub) { instance_double(HttpStub::Server::Stub::Stub, response: response, stub_uri: stub_uri) }

  let(:stub_registry)         { instance_double(HttpStub::Server::Stub::Registry).as_null_object }
  let(:match_result_registry) { instance_double(HttpStub::Server::Registry).as_null_object }

  let(:controller) { HttpStub::Server::Stub::Controller.new(stub_registry, match_result_registry) }

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
      expect(stub_registry).to receive(:add).with(the_stub, logger)

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

  describe "#match" do

    let(:calculated_stub_response) { instance_double(HttpStub::Server::Stub::Response::Base) }

    subject { controller.match(request, logger) }

    before(:example) do
      allow(stub_registry).to receive(:match).with(request, logger).and_return(matched_stub)
      allow(the_stub).to receive(:response_for).and_return(calculated_stub_response)
      allow(match_result_registry).to receive(:add)
    end

    describe "when a stub has been registered that matches the request" do

      let(:matched_stub) { the_stub }

      it "calculates the stubs response based on the request" do
        expect(the_stub).to receive(:response_for).with(request)

        subject
      end

      it "determines the match result for the request, calculated response and stub" do
        expect(HttpStub::Server::Stub::Match::Result).to receive(:new).with(request, calculated_stub_response, the_stub)

        subject
      end

      it "adds the match result to the match result registry" do
        expect(match_result_registry).to(
          receive(:add).with(an_instance_of(HttpStub::Server::Stub::Match::Result), logger)
        )

        subject
      end

      it "returns the calculated response" do
        expect(subject).to eql(calculated_stub_response)
      end

    end

    describe "when no stub matches the request" do

      let(:matched_stub) { nil }

      it "returns a not found response" do
        expect(subject).to eql(HttpStub::Server::Response::NOT_FOUND)
      end

      it "creates a match result for request with the not found response and no stub" do
        expect(HttpStub::Server::Stub::Match::Result).to(
          receive(:new).with(request, HttpStub::Server::Response::NOT_FOUND, nil)
        )

        subject
      end

      it "adds the match result to the match result registry" do
        expect(match_result_registry).to(
          receive(:add).with(an_instance_of(HttpStub::Server::Stub::Match::Result), logger)
        )

        subject
      end

    end

  end

  describe "#clear" do

    subject { controller.clear(logger) }

    it "clears the stub registry" do
      expect(stub_registry).to receive(:clear).with(logger)

      subject
    end

    it "clears the match result registry" do
      expect(match_result_registry).to receive(:clear).with(logger)

      subject
    end

  end

end
