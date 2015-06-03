describe HttpStub::Server::Stub::RequestParser do

  let(:request_parser) { described_class }

  describe "::parse" do

    let(:params)    { {} }
    let(:body_hash) { {} }
    let(:request)   { instance_double(Rack::Request, params: params, body: StringIO.new(body_hash.to_json)) }

    subject { request_parser.parse(request) }

    context "when the request contains a payload parameter" do

      let(:payload) { HttpStub::StubFixture.new.server_payload }
      let(:params)  { { "payload" => payload.to_json } }

      it "consolidates any files into the payload" do
        expect(HttpStub::Server::Stub::PayloadFileConsolidator).to receive(:consolidate!).with(payload, request)

        subject
      end

      it "returns the consolidated payload" do
        consolidated_payload = { consolidated_payload_key: "consolidated payload value" }
        allow(HttpStub::Server::Stub::PayloadFileConsolidator).to(
          receive(:consolidate!).and_return(consolidated_payload)
        )

        expect(subject).to eql(consolidated_payload)
      end

    end

    context "when the request body contains the payload (for API backwards compatibility)" do

      let(:body_hash) { HttpStub::StubFixture.new.server_payload }

      it "consolidates any files into the body" do
        expect(HttpStub::Server::Stub::PayloadFileConsolidator).to receive(:consolidate!).with(body_hash, request)

        subject
      end

      it "returns the consolidated body" do
        consolidated_body = { consolidated_body_key: "consolidated body value" }
        allow(HttpStub::Server::Stub::PayloadFileConsolidator).to receive(:consolidate!).and_return(consolidated_body)

        expect(subject).to eql(consolidated_body)
      end

    end

  end

end
