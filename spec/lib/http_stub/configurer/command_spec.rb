describe HttpStub::Configurer::Command do

  let(:processor) { double(HttpStub::Configurer::CommandProcessor) }
  let(:args) { { processor: processor, request: double("HttpRequest"), description: "Some Description" } }

  let(:command) { HttpStub::Configurer::Command.new(args) }

  describe "#execute" do

    it "delegates to the provided processor" do
      expect(processor).to receive(:process).with(command)

      command.execute
    end

  end

  describe "#resetable" do

    describe "when created with a resetable flag that is true" do

      before(:example) { args.merge!(resetable: true) }

      it "returns true" do
        expect(command.resetable?).to be_truthy
      end

    end

    describe "when created without a resetable flag" do

      it "returns false" do
        expect(command.resetable?).to be_falsey
      end

    end

  end

end
