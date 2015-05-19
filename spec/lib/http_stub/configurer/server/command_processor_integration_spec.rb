describe HttpStub::Configurer::Server::CommandProcessor do

  let(:command) { HttpStub::Configurer::Server::Command.new(request: request, description: "performing an operation") }
  let(:server_base_uri) { "http://localhost:8001" }

  let(:configurer) do
    double(HttpStub::Configurer, get_base_uri: server_base_uri, get_host: "localhost", get_port: 8001)
  end

  let(:command_processor) { HttpStub::Configurer::Server::CommandProcessor.new(configurer) }

  describe "#process" do

    subject { command_processor.process(command) }

    context "when the server is running" do

      include_context "server integration"

      describe "and the server responds with a 200 response" do

        let(:request) { create_get_request("/stubs") }

        it "executes without error" do
          expect { subject }.not_to raise_error
        end

      end

      describe "and the server responds with a non-200 response" do

        let(:request) { create_get_request("/causes_error") }

        it "raises an exception that includes the server base URI" do
          expect { subject }.to raise_error(/#{server_base_uri}/)
        end

        it "raises an exception that includes the commands description" do
          expect { subject }.to raise_error(/performing an operation/)
        end

      end

    end

    context "when the server is unavailable" do

      let(:request) { create_get_request("/does/not/exist") }

      it "raises an exception that includes the server base URI" do
        expect { subject }.to raise_error(/#{server_base_uri}/)
      end

      it "raises an exception that includes the commands description" do
        expect { subject }.to raise_error(/performing an operation/)
      end

    end

    def create_get_request(path)
      HttpStub::Configurer::Request::Http::Basic.new(Net::HTTP::Get.new(path))
    end

  end

end
