describe HttpStub::Server::Stub::Match::Controller do

  let(:request_parameters) { {} }
  let(:session)            { instance_double(HttpStub::Server::Session::Session) }
  let(:request)            do
    instance_double(HttpStub::Server::Request::Request, parameters: request_parameters, session: session)
  end

  let(:controller) { described_class.new }

  describe "#last_match" do

    let(:uri)                { "/some/endpoint/uri" }
    let(:method)             { "PATCH" }
    let(:request_parameters) { { uri: uri, method: method } }
    let(:logger)             { instance_double(Logger) }

    subject { controller.last_match(request, logger) }

    it "finds the match in the users session having the uri requested" do
      expect(session).to receive(:last_match).with(hash_including(uri: uri), anything)

      subject
    end

    it "finds the match in the users session having the HTTP method requested" do
      expect(session).to receive(:last_match).with(hash_including(method: method), anything)

      subject
    end

    it "finds the match using the provided logger for diagnostics" do
      expect(session).to receive(:last_match).with(anything, logger)

      subject
    end

    context "when a match is found" do

      let(:match_json) { "some match JSON" }
      let(:match)      { instance_double(HttpStub::Server::Stub::Match::Match, to_json: match_json) }

      before(:example) { allow(session).to receive(:last_match).and_return(match) }

      it "creates an ok response containing the JSON representation of the match" do
        expect(HttpStub::Server::Response).to receive(:ok).with("body" => match_json)

        subject
      end

      it "returns the response" do
        response = instance_double(HttpStub::Server::Stub::Response::Text)
        allow(HttpStub::Server::Response).to receive(:ok).and_return(response)

        expect(subject).to eql(response)
      end

    end

    context "when a match is not found" do

      before(:example) { allow(session).to receive(:last_match).and_return(nil) }

      it "returns a not found response" do
        expect(subject).to eql(HttpStub::Server::Response::NOT_FOUND)
      end

    end

  end

  describe "#matches" do

    let(:matches) { (1..3).map { instance_double(HttpStub::Server::Stub::Match::Match) } }

    subject { controller.matches(request) }

    before(:example) { allow(session).to receive(:matches).and_return(matches) }

    it "retrieves all matches from the users session" do
      expect(session).to receive(:matches)

      subject
    end

    it "returns the matches" do
      expect(subject).to eql(matches)
    end

  end

  describe "#matches" do

    let(:misses) { (1..3).map { instance_double(HttpStub::Server::Stub::Match::Miss) } }

    subject { controller.misses(request) }

    before(:example) { allow(session).to receive(:misses).and_return(misses) }

    it "retrieves all misses from the users session" do
      expect(session).to receive(:misses)

      subject
    end

    it "returns the misses" do
      expect(subject).to eql(misses)
    end

  end

end
