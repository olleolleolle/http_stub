describe HttpStub::Configurer::PostInitializeCommandProcessor do

  let(:command) { double(HttpStub::Configurer::Command).as_null_object }

  let(:pre_processor) { double(HttpStub::Configurer::PreInitializeCommandProcessor) }
  let(:post_processor) { HttpStub::Configurer::PostInitializeCommandProcessor.new(pre_processor) }

  describe "#process" do

    it "should immediately execute the provided command" do
      command.should_receive(:execute)

      post_processor.process(command)
    end

    it "should not execute the command via the pre initialize command processor" do
      pre_processor.should_not_receive(:execute)

      post_processor.process(command)
    end

  end

  describe "#replay" do

    it "should replay any commands known by the pre initialize command processor" do
      pre_processor.should_receive(:replay)

      post_processor.replay
    end

  end

end
