describe HttpStub::Configurer::Server::Facade do

  let(:configurer)        { double(HttpStub::Configurer) }
  let(:request_processor) { instance_double(HttpStub::Configurer::Server::RequestProcessor) }

  let(:facade) { HttpStub::Configurer::Server::Facade.new(configurer) }

  before(:example) do
    allow(HttpStub::Configurer::Server::RequestProcessor).to receive(:new).and_return(request_processor)
  end
  
  describe "constructor" do

    it "creates a request processor with the provided configurer" do
      expect(HttpStub::Configurer::Server::RequestProcessor).to receive(:new).with(configurer)
      
      facade
    end

  end

  describe "#stub_response" do

    let(:stub_uri) { "/some/stub/uri" }
    let(:request)  { instance_double(HttpStub::Configurer::Request::Stub, stub_uri: stub_uri) }

    subject { facade.stub_response(request) }

    before(:example) { allow(request_processor).to receive(:submit) }

    it "submits the stub request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the stub via its stub uri" do
      expect(request_processor).to receive(:submit).with(hash_including(description: "stubbing '#{stub_uri}'"))

      subject
    end

  end

  describe "#stub_activator" do

    let(:activation_uri) { "/some/activation/uri" }
    let(:request) { instance_double(HttpStub::Configurer::Request::StubActivator, activation_uri: activation_uri) }

    subject { facade.stub_activator(request) }

    before(:example) { allow(request_processor).to receive(:submit) }

    it "submits the stub request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the stub via its activation uri" do
      expect(request_processor).to(
        receive(:submit).with(hash_including(description: "registering activator '#{activation_uri}'"))
      )

      subject
    end

  end

  describe "#activate" do

    let(:uri)     { "/some/activation/uri" }
    let(:request) { instance_double(Net::HTTP::Get) }

    subject { facade.activate(uri) }

    before(:example) do
      allow(Net::HTTP::Get).to receive(:new).and_return(request)
      allow(request_processor).to receive(:submit)
    end

    it "creates a GET request for the uri" do
      expect(Net::HTTP::Get).to receive(:new).with(uri).and_return(request)

      subject
    end

    it "submits the GET request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the activation request via the provided uri" do
      expect(request_processor).to receive(:submit).with(hash_including(description: "activating '#{uri}'"))

      subject
    end

  end

  describe "#remember_stubs" do

    let(:request) { instance_double(Net::HTTP::Post) }

    subject { facade.remember_stubs }

    before(:example) do
      allow(Net::HTTP::Post).to receive(:new).and_return(request)
      allow(request).to receive(:body=)
      allow(request_processor).to receive(:submit)
    end

    it "creates a POST request for /stubs/memory endpoint" do
      expect(Net::HTTP::Post).to receive(:new).with("/stubs/memory").and_return(request)

      subject
    end

    it "establishes an empty body on the POST request" do
      expect(request).to receive(:body=).with("")

      subject
    end

    it "submits the POST request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the request as committing the servers stubs to memory" do
      expect(request_processor).to receive(:submit).with(hash_including(description: "committing stubs to memory"))

      subject
    end

  end

  describe "#recall_stubs" do

    let(:request) { instance_double(Net::HTTP::Get) }

    subject { facade.recall_stubs }

    before(:example) do
      allow(Net::HTTP::Get).to receive(:new).and_return(request)
      allow(request_processor).to receive(:submit)
    end

    it "creates a POST request for /stubs/memory endpoint" do
      expect(Net::HTTP::Get).to receive(:new).with("/stubs/memory").and_return(request)

      subject
    end

    it "submits the GET request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the request as recalling the servers stubs in memory" do
      expect(request_processor).to receive(:submit).with(hash_including(description: "recalling stubs in memory"))

      subject
    end

  end

  describe "#clear_stubs" do

    let(:request) { instance_double(Net::HTTP::Delete) }

    subject { facade.clear_stubs }

    before(:example) do
      allow(Net::HTTP::Delete).to receive(:new).and_return(request)
      allow(request_processor).to receive(:submit)
    end

    it "creates a DELETE request for the /stubs endpoint" do
      expect(Net::HTTP::Delete).to receive(:new).with("/stubs").and_return(request)

      subject
    end

    it "adds the DELETE request to the server state" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the request as clearing the server stubs" do
      expect(request_processor).to receive(:submit).with(hash_including(description: "clearing stubs"))

      subject
    end

  end

  describe "#clear_activators" do

    let(:request) { instance_double(Net::HTTP::Delete) }

    subject { facade.clear_activators }

    before(:example) do
      allow(Net::HTTP::Delete).to receive(:new).and_return(request)
      allow(request_processor).to receive(:submit)
    end

    it "creates a DELETE request for the /stubs/activators endpoint" do
      expect(Net::HTTP::Delete).to receive(:new).with("/stubs/activators").and_return(request)

      subject
    end

    it "adds the DELETE request to the server state" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the request as clearing the server stub activators" do
      expect(request_processor).to receive(:submit).with(hash_including(description: "clearing activators"))

      subject
    end

  end

  describe "#server_has_started" do

    it "informs the request processor to disable buffering requests" do
      expect(request_processor).to receive(:disable_buffering!)

      facade.server_has_started
    end

  end

  describe "#flush_requests" do

    it "informs the request processor to flush it's requests" do
      expect(request_processor).to receive(:flush!)

      facade.flush_requests
    end

  end

end
