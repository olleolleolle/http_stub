describe HttpStub::Server::Stub do

  let(:args) { HttpStub::StubFixture.new.server_payload }

  describe "::create" do

    subject { HttpStub::Server::Stub.create(args) }

    it "creates a stub instance with the provided arguments" do
      expect(HttpStub::Server::Stub::Instance).to receive(:new).with(args)

      subject
    end

    it "returns the created stub" do
      the_stub = instance_double(HttpStub::Server::Stub::Instance)
      allow(HttpStub::Server::Stub::Instance).to receive(:new).and_return(the_stub)

      expect(subject).to eql(the_stub)
    end

  end

end
