describe HttpStub::Server::Stub::Controller do

  let(:request_parameters) { {} }
  let(:request)            { HttpStub::Server::RequestFixture.create(parameters: request_parameters) }
  let(:session)            { request.session }
  let(:logger)             { instance_double(Logger) }
  let(:stub_uri)           { "/some/stub/uri" }
  let(:the_stub)           { instance_double(HttpStub::Server::Stub::Stub, uri: stub_uri) }

  let(:controller) { described_class.new }

  describe "#match" do

    let(:matched_stub) { nil }

    let(:calculated_stub_response) { HttpStub::Server::Stub::ResponseFixture.create }

    subject { controller.match(request, logger) }

    before(:example) do
      allow(session).to receive(:match).and_return(matched_stub)
      allow(the_stub).to receive(:response_for).and_return(calculated_stub_response)
    end

    it "evaluates the matching stub for the user" do
      allow(session).to receive(:add_match)
      allow(session).to receive(:add_miss)
      expect(session).to receive(:match).with(request, logger)

      subject
    end

    describe "when a stub matches the request" do

      let(:matched_stub) { the_stub }

      before(:example) { allow(session).to receive(:add_match) }

      it "calculates the stubs response based on the request" do
        expect(the_stub).to receive(:response_for).with(request)

        subject
      end

      it "creates a match for the request, calculated response and stub" do
        expect(HttpStub::Server::Stub::Match::Match).to receive(:new).with(request, calculated_stub_response, the_stub)

        subject
      end

      it "adds the match to the users session" do
        match = instance_double(HttpStub::Server::Stub::Match::Match)
        allow(HttpStub::Server::Stub::Match::Match).to receive(:new).and_return(match)
        expect(session).to receive(:add_match).with(match, logger)

        subject
      end

      it "does not add to the users session" do
        expect(session).to_not receive(:add_miss)

        subject
      end

      it "returns the calculated response" do
        expect(subject).to eql(calculated_stub_response)
      end

    end

    describe "when no stub matches the request" do

      let(:matched_stub) { nil }

      before(:example) { allow(session).to receive(:add_miss) }

      it "returns a not found response" do
        expect(subject).to eql(HttpStub::Server::Response::NOT_FOUND)
      end

      it "creates a miss for the request" do
        expect(HttpStub::Server::Stub::Match::Miss).to receive(:new).with(request)

        subject
      end

      it "adds the miss to the users session" do
        miss = instance_double(HttpStub::Server::Stub::Match::Miss)
        allow(HttpStub::Server::Stub::Match::Miss).to receive(:new).and_return(miss)
        expect(session).to receive(:add_miss).with(miss, logger)

        subject
      end

      it "does not add to the match to the users session" do
        expect(session).to_not receive(:add_match)

        subject
      end

    end

  end

  describe "#find" do

    let(:id)                 { SecureRandom.uuid }
    let(:request_parameters) { { stub_id: id } }

    subject { controller.find(request, logger) }

    before(:example) { allow(session).to receive(:find_stub).and_return(the_stub) }

    it "finds the stub with the parameterized id in the user session" do
      expect(session).to receive(:find_stub).with(id, logger)

      subject
    end

    it "returns the found stub" do
      expect(subject).to eql(the_stub)
    end

  end

  describe "#find_all" do

    let(:stubs) { (1..3).map { instance_double(HttpStub::Server::Stub::Stub) } }

    subject { controller.find_all(request) }

    before(:example) { allow(session).to receive(:stubs).and_return(stubs) }

    it "retrieves all stubs from the users session" do
      expect(session).to receive(:stubs)

      subject
    end

    it "returns the stubs" do
      expect(subject).to eql(stubs)
    end

  end

  describe "#reset" do

    subject { controller.reset(request, logger) }

    it "resets the users session" do
      expect(session).to receive(:reset).with(logger)

      subject
    end

  end

end
