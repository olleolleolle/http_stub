describe HttpStub::Server::StdoutLogger do

  describe "::info" do

    let(:message) { "some message"}

    subject { described_class.info(message) }

    it "writes the message to std out" do
      expect(described_class).to receive(:puts).with(message)

      subject
    end

  end

end
