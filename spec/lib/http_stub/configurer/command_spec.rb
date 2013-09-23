describe HttpStub::Configurer::Command do

  let(:processor) { double(HttpStub::Configurer::CommandProcessor) }
  let(:options) { { processor: processor, request: double("HttpRequest"), description: "Some Description" } }

  let(:command) { HttpStub::Configurer::Command.new(options) }

  describe "#execute" do

    it "should delegate to the provided processor" do
      processor.should_receive(:process).with(command)

      command.execute
    end

  end

  describe "#resetable" do

    describe "when created with a resetable flag that is true" do

      before(:each) { options.merge!(resetable: true) }

      it "should return true" do
        command.resetable?.should be_true
      end

    end

    describe "when created without a resetable flag" do

      it "should return false" do
        command.resetable?.should be_false
      end

    end

  end

end
