describe HttpStub::Configurer::CommandProcessor, "when the server is running" do
  include_context "server integration"

  let(:configurer) { double(HttpStub::Configurer, get_host: "localhost", get_port: 8001) }
  let(:command) { HttpStub::Configurer::Command.new(request: request, description: "performing an operation") }

  let(:command_processor) { HttpStub::Configurer::CommandProcessor.new(configurer) }

  describe "#process" do

    describe "when the server responds with a 200 response" do

      let(:request) { Net::HTTP::Get.new("/stubs") }

      it "should execute without error" do
        lambda { command_processor.process(command) }.should_not raise_error
      end

    end

    describe "when the server responds with a non-200 response" do

      let(:request) { Net::HTTP::Get.new("/causes_error") }

      it "should raise an exception that includes the commands description" do
        lambda { command_processor.process(command) }.should raise_error(/performing an operation/)
      end

    end

  end

end
