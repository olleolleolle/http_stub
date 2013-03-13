describe HttpStub::Configurer::BufferedCommandProcessor do

  let(:processor) { HttpStub::Configurer::BufferedCommandProcessor.new }

  describe "#flush" do

    describe "when a number of commands have been processed" do

      let(:commands) do
        (1..3).map { |i| double("Command#{i}").as_null_object }
      end

      before(:each) do
        commands.each { |command| processor.process(command) }
      end

      it "should execute the buffered commands" do
        commands.each { |command| command.should_receive(:execute) }

        processor.flush()
      end

      describe "and those commands have already been flushed" do

        before(:each) { processor.flush() }

        it "should not re-execute those commands" do
          commands.each { |command| command.should_not_receive(:execute) }

          processor.flush()
        end

      end

    end

    describe "when no commands have been processed" do

      it "should execute without error" do
        lambda { processor.flush() }.should_not raise_error
      end

    end

  end

end
