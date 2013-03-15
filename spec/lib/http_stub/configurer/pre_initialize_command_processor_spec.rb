describe HttpStub::Configurer::PreInitializeCommandProcessor do

  let(:processor) { HttpStub::Configurer::PreInitializeCommandProcessor.new }

  describe "#replay" do

    describe "when a number of commands have been processed" do

      let(:commands) do
        (1..3).map { |i| double("Command#{i}").as_null_object }
      end

      before(:each) do
        commands.each { |command| processor.process(command) }
      end

      it "should execute the cached commands" do
        commands.each { |command| command.should_receive(:execute) }

        processor.replay()
      end

      describe "and those commands have already been replayed" do

        before(:each) { processor.replay() }

        it "should re-replay those commands" do
          commands.each { |command| command.should_receive(:execute) }

          processor.replay()
        end

      end

    end

    describe "when no commands have been processed" do

      it "should execute without error" do
        lambda { processor.replay() }.should_not raise_error
      end

    end

  end

end
