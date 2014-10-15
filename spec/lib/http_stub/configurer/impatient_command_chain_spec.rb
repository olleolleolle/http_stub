describe HttpStub::Configurer::ImpatientCommandChain do

  let(:command) { double(HttpStub::Configurer::Command) }

  let(:command_chain) { HttpStub::Configurer::ImpatientCommandChain.new() }

  describe "#<<" do

    it "immediately execute the provided command" do
      expect(command).to receive(:execute)

      command_chain << command
    end

  end

end
