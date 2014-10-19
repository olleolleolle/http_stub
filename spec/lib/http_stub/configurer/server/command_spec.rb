describe HttpStub::Configurer::Server::Command do

  let(:processor) { instance_double(HttpStub::Configurer::Server::CommandProcessor) }
  let(:args)      { { processor: processor, request: double("HttpRequest"), description: "Some Description" } }

  let(:command) { HttpStub::Configurer::Server::Command.new(args) }

  describe "#execute" do

    it "delegates to the provided processor" do
      expect(processor).to receive(:process).with(command)

      command.execute
    end

  end

  describe "#resetable" do

    subject { command.resetable? }

    describe "when created with a resetable flag that is true" do

      before(:example) { args.merge!(resetable: true) }

      it "returns true" do
        expect(subject).to be(true)
      end

    end

    describe "when created without a resetable flag" do

      it "returns false" do
        expect(subject).to be(false)
      end

    end

  end

end
