describe HttpStub::Configurer::Server::RequestProcessor do

  let(:configurer)        { double(HttpStub::Configurer) }
  let(:command_processor) { instance_double(HttpStub::Configurer::Server::CommandProcessor) }
  let(:buffered_command_processor)  { instance_double(HttpStub::Configurer::Server::BufferedCommandProcessor) }

  let(:request_processor)     { HttpStub::Configurer::Server::RequestProcessor.new(configurer) }

  before(:example) do
    allow(HttpStub::Configurer::Server::CommandProcessor).to receive(:new).and_return(command_processor)
    allow(HttpStub::Configurer::Server::BufferedCommandProcessor).to(
      receive(:new).and_return(buffered_command_processor)
    )
  end

  describe "constructor" do

    it "creates a command processor for the configurer" do
      expect(HttpStub::Configurer::Server::CommandProcessor).to receive(:new).with(configurer)

      request_processor
    end
    
    it "creates a buffered command processor that flushes via the command processor" do
      expect(HttpStub::Configurer::Server::BufferedCommandProcessor).to receive(:new).with(command_processor)

      request_processor
    end

  end

  describe "#submit" do

    let(:args) { { some_arg_key: "some arg value" } }

    subject { request_processor.submit(args) }

    shared_examples_for "submitting a request to the server" do |processor_description|

      let(:command) { instance_double(HttpStub::Configurer::Server::Command) }

      before(:each) { allow(active_command_processor).to receive(:process) }

      it "creates a command for the provided arguments" do
        expect(HttpStub::Configurer::Server::Command).to receive(:new).with(hash_including(args)).and_return(command)

        subject
      end

      it "processes the command via the #{processor_description}" do
        allow(HttpStub::Configurer::Server::Command).to receive(:new).and_return(command)
        expect(active_command_processor).to receive(:process).with(command)

        subject
      end

    end

    context "when request buffering is enabled" do

      let(:active_command_processor) { buffered_command_processor }

      it_behaves_like "submitting a request to the server", "buffered command processor"

    end

    context "when request buffering is disabled" do

      let(:active_command_processor) { command_processor }

      before(:example) { request_processor.disable_buffering! }

      it_behaves_like "submitting a request to the server", "command processor"

    end

  end

  describe "#flush!" do

    subject { request_processor.flush! }

    before(:example) { allow(buffered_command_processor).to receive(:flush) }

    it "delegates to the buffered command processor" do
      expect(buffered_command_processor).to receive(:flush)

      subject
    end

    it "disables request buffering" do
      expect(request_processor).to receive(:disable_buffering!)

      subject
    end

  end

end
