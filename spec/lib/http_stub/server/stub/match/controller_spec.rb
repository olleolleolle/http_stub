describe HttpStub::Server::Stub::Match::Controller do

  let(:registry) { instance_double(HttpStub::Server::Registry) }

  let(:controller) { described_class.new(registry) }

  describe "#find_last" do

    let(:uri)        { "/some/endpoint/uri" }
    let(:method)     { "PATCH" }
    let(:parameters) { { uri: uri, method: method } }
    let(:request)    { instance_double(HttpStub::Server::Request::Request, parameters: parameters) }
    let(:logger)     { instance_double(Logger) }

    subject { controller.find_last(request, logger) }

    it "finds the match in the registry with the uri requested" do
      expect(registry).to receive(:find).with(hash_including(uri: uri), anything)

      subject
    end

    it "finds the match in the registry with the HTTP method requested" do
      expect(registry).to receive(:find).with(hash_including(method: method), anything)

      subject
    end

    it "finds the match using the provided logger for diagnostics" do
      expect(registry).to receive(:find).with(anything, logger)

      subject
    end

    context "when a match is found" do

      let(:match_json) { "some match JSON" }
      let(:match)      { instance_double(HttpStub::Server::Stub::Match::Match, to_json: match_json) }

      before(:example) { allow(registry).to receive(:find).and_return(match) }

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

      before(:example) { allow(registry).to receive(:find).and_return(nil) }

      it "returns a not found response" do
        expect(subject).to eql(HttpStub::Server::Response::NOT_FOUND)
      end

    end

  end

end
