describe HttpStub::Configurer::Server::CommandProcessor do

  let(:server_host)     { "localhost" }
  let(:server_port)     { 8001 }
  let(:server_base_uri) { "http://#{server_host}:#{server_port}" }
  let(:configuration)   do
    double(HttpStub::Configurer::Server::Configuration, base_uri: server_base_uri, host: server_host, port: server_port)
  end

  let(:command_processor) { HttpStub::Configurer::Server::CommandProcessor.new(configuration) }

  describe "#process" do

    let(:command) do
      HttpStub::Configurer::Server::Command.new(request: request, description: "performing an operation")
    end

    subject { command_processor.process(command) }

    context "when the server is running" do
      include_context "server integration"

      describe "and the server responds with a 200 response" do

        let(:request) { create_get_request("stubs") }

        it "executes without error" do
          expect { subject }.not_to raise_error
        end

        it "returns the server response" do
          expect(subject).to be_a(Net::HTTPResponse)
        end

      end

      describe "and the server responds with a non-200 response" do

        let(:request) { create_get_request("causes_error") }

        it "raises an exception that includes the server base URI" do
          expect { subject }.to raise_error(/#{server_base_uri}/)
        end

        it "raises an exception that includes the commands description" do
          expect { subject }.to raise_error(/performing an operation/)
        end

      end

    end

    context "when the server is unavailable" do

      subject { command_processor.process(command, open_timeout: 1) }

      let(:request) { create_get_request("does/not/exist") }

      it "raises an exception that includes the server base URI" do
        expect { subject }.to raise_error(/#{server_base_uri}/)
      end

      it "raises an exception that includes the commands description" do
        expect { subject }.to raise_error(/performing an operation/)
      end

    end

    def create_get_request(path)
      HttpStub::Configurer::Request::Http::Basic.new(method: :get, path: path)
    end

  end

end
