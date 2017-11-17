describe HttpStub::Client do

  describe "::create" do

    let(:server_uri) { "http://some.server.uri" }

    subject { described_class.create(server_uri) }

    it "returns a client" do
      expect(subject).to be_an_instance_of(HttpStub::Client::Client)
    end

  end

end
