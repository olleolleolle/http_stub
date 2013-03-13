describe HttpStub::Configurer::ImmediateCommandProcessor do

  let(:command) { double("Command").as_null_object }

  let(:processor) { HttpStub::Configurer::ImmediateCommandProcessor.new }

  describe "#process" do

    it "should execute the provided command" do
      command.should_receive(:execute)

      processor.process(command)
    end

  end

  describe "#flush" do

    describe "when a command has been processed" do

      before(:each) { processor.process(command) }

      it "should not re-execute the command" do
        command.should_not_receive(:execute)

        processor.flush
      end

    end


  end

end
