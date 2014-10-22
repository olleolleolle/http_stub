describe HttpStub::Configurer::Server::BufferedCommandProcessor do

  let(:command_processor) { instance_double(HttpStub::Configurer::Server::CommandProcessor) }

  let(:buffered_command_processor) { HttpStub::Configurer::Server::BufferedCommandProcessor.new(command_processor) }

  describe "#flush" do

    subject { buffered_command_processor.flush }

    describe "when a number of commands have been buffered via processing" do

      let(:commands) { (1..3).map { instance_double(HttpStub::Configurer::Server::Command) } }

      before(:example) { commands.each { |command| buffered_command_processor.process(command) } }

      it "processes the buffered commands via the command processor" do
        commands.each { |command| expect(command_processor).to receive(:process).with(command) }

        subject
      end

    end

    describe "when no commands have been buffered" do

      it "executes without error" do
        expect { subject }.not_to raise_error
      end

    end

  end

end
