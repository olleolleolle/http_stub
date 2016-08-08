describe HttpStub::Server::Stub::Payload::BaseUriModifier do

  let(:modifier) { described_class }

  describe "::modify!" do

    let(:payload)         { HttpStub::StubFixture.new.server_payload }
    let(:base_uri)        { "http://base.uri:8888" }
    let(:request)         { instance_double(HttpStub::Server::Request::Request, base_uri: base_uri) }

    subject { modifier.modify!(payload, request) }

    it "alters the payload to include the servers base uri" do
      expected_payload = payload.clone.merge("base_uri" => base_uri)

      subject

      expect(payload).to eql(expected_payload)
    end

  end

end
