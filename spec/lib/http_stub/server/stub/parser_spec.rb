describe HttpStub::Server::Stub::Parser do

  let(:parser) { described_class }

  describe "::parse" do

    let(:parameters) { {} }
    let(:body_hash)  { {} }
    let(:request)    do
      instance_double(HttpStub::Server::Request::Request, parameters: parameters, body: body_hash.to_json)
    end

    subject { parser.parse(request) }

    context "when the request contains a payload parameter" do

      let(:payload)    { HttpStub::StubFixture.new.server_payload }
      let(:parameters) { { "payload" => payload.to_json } }

      it "modifies the payload" do
        expect(HttpStub::Server::Stub::Payload).to receive(:modify!).with(payload, request)

        subject
      end

      it "returns the modified payload" do
        modified_payload = { modified_payload_key: "modified payload value" }
        allow(HttpStub::Server::Stub::Payload).to receive(:modify!).and_return(modified_payload)

        expect(subject).to eql(modified_payload)
      end

    end

    context "when the request body contains the payload (for API backwards compatibility)" do

      let(:body_hash) { HttpStub::StubFixture.new.server_payload }

      it "modifies the body" do
        expect(HttpStub::Server::Stub::Payload).to receive(:modify!).with(body_hash, request)

        subject
      end

      it "returns the modified body" do
        modified_body = { modified_body_key: "modified body value" }
        allow(HttpStub::Server::Stub::Payload).to receive(:modify!).and_return(modified_body)

        expect(subject).to eql(modified_body)
      end

    end

  end

end
