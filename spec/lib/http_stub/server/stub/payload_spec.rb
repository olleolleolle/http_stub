describe HttpStub::Server::Stub::Payload do

  describe "::modify!" do

    let(:payload) { HttpStub::StubFixture.new.server_payload }
    let(:request) { instance_double(HttpStub::Server::Request::Request) }

    subject { described_class.modify!(payload, request) }

    before(:example) do
      allow(HttpStub::Server::Stub::Payload::BaseUriModifier).to receive(:modify!)
      allow(HttpStub::Server::Stub::Payload::ResponseBodyModifier).to receive(:modify!)
    end

    it "modifies the payloads base uri" do
      expect(HttpStub::Server::Stub::Payload::BaseUriModifier).to receive(:modify!).with(payload, request)

      subject
    end

    it "modifies the payloads request body" do
      expect(HttpStub::Server::Stub::Payload::ResponseBodyModifier).to receive(:modify!).with(payload, request)

      subject
    end

    it "returns the potentially modified payload" do
      expect(subject).to be(payload)
    end

  end

end
