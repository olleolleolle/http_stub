describe HttpStub::Configurer::ImpatientCommandChain do

  let(:command) { double(HttpStub::Configurer::Command) }

  let(:command_chain) { HttpStub::Configurer::ImpatientCommandChain.new() }

  describe "#<<" do

    it "should immediately execute the provided command" do
      command.should_receive(:execute)

      command_chain << command
    end

  end

end
