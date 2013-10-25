describe HttpStub::Configurer::CommandProcessor do

  let(:command) { HttpStub::Configurer::Command.new(request: request, description: "performing an operation") }
  let(:server_base_uri) { "http://localhost:8001" }
  let(:configurer) do
    double(HttpStub::Configurer, get_base_uri: server_base_uri, get_host: "localhost", get_port: 8001)
  end

  let(:command_processor) { HttpStub::Configurer::CommandProcessor.new(configurer) }

  context "when the server is running" do

    include_context "server integration"

    describe "#process" do

      describe "when the server responds with a 200 response" do

        let(:request) { Net::HTTP::Get.new("/stubs") }

        it "should execute without error" do
          lambda { command_processor.process(command) }.should_not raise_error
        end

      end

      describe "when the server responds with a non-200 response" do

        let(:request) { Net::HTTP::Get.new("/causes_error") }

        it "should raise an exception that includes the server base URI" do
          lambda { command_processor.process(command) }.should raise_error(/#{server_base_uri}/)
        end

        it "should raise an exception that includes the commands description" do
          lambda { command_processor.process(command) }.should raise_error(/performing an operation/)
        end

      end

    end

  end

  context "when the server is unavailable" do

    let(:request) { Net::HTTP::Get.new("/does/not/exist") }

    describe "#process" do

      it "should raise an exception that includes the server base URI" do
        lambda { command_processor.process(command) }.should raise_error(/#{server_base_uri}/)
      end

      it "should raise an exception that includes the commands description" do
        lambda { command_processor.process(command) }.should raise_error(/performing an operation/)
      end

    end

  end

end
