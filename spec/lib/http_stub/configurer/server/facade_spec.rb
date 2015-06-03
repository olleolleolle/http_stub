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

    let(:model_description) { "some model description" }
    let(:model)             { instance_double(HttpStub::Configurer::Request::Stub, to_s: model_description) }
    let(:request)           { instance_double(HttpStub::Configurer::Request::Http::Multipart) }

    subject { facade.stub_response(model) }

    before(:example) do
      allow(request_processor).to receive(:submit)
      allow(HttpStub::Configurer::Request::Http::Factory).to receive(:stub).and_return(request)
    end

    it "creates a stub request with the provided model" do
      expect(HttpStub::Configurer::Request::Http::Factory).to receive(:stub).with(model)

      subject
    end

    it "submits the stub request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the model via its string representation" do
      expect(request_processor).to receive(:submit).with(hash_including(description: "stubbing '#{model_description}'"))

      subject
    end

  end

  describe "#define_scenario" do

    let(:model_description) { "some model description" }
    let(:model)             { instance_double(HttpStub::Configurer::Request::Scenario, to_s: model_description) }
    let(:request)           { instance_double(HttpStub::Configurer::Request::Http::Multipart) }

    subject { facade.define_scenario(model) }

    before(:example) do
      allow(request_processor).to receive(:submit)
      allow(HttpStub::Configurer::Request::Http::Factory).to receive(:scenario).and_return(request)
    end

    it "creates a scenario request with the provided model" do
      expect(HttpStub::Configurer::Request::Http::Factory).to receive(:scenario).with(model)

      subject
    end

    it "submits the scenario request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the model via its string representation" do
      expect(request_processor).to(
        receive(:submit).with(hash_including(description: "registering scenario '#{model_description}'"))
      )

      subject
    end

  end

  describe "#activate" do

    let(:uri)     { "/some/activation/uri" }
    let(:request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { facade.activate(uri) }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Factory).to receive(:activate).and_return(request)
      allow(request_processor).to receive(:submit)
    end

    it "creates an activation request for the uri" do
      expect(HttpStub::Configurer::Request::Http::Factory).to receive(:activate).with(uri).and_return(request)

      subject
    end

    it "submits the request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the activation request via the provided uri" do
      expect(request_processor).to receive(:submit).with(hash_including(description: "activating '#{uri}'"))

      subject
    end

  end

  describe "#remember_stubs" do

    let(:request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { facade.remember_stubs }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Factory).to receive(:post).and_return(request)
      allow(request_processor).to receive(:submit)
    end

    it "creates a POST request for /stubs/memory endpoint" do
      expect(HttpStub::Configurer::Request::Http::Factory).to receive(:post).with("/stubs/memory").and_return(request)

      subject
    end

    it "submits the request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the request as committing the servers stubs to memory" do
      expect(request_processor).to receive(:submit).with(hash_including(description: "committing stubs to memory"))

      subject
    end

  end

  describe "#recall_stubs" do

    let(:request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { facade.recall_stubs }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Factory).to receive(:get).and_return(request)
      allow(request_processor).to receive(:submit)
    end

    it "creates a GET request for /stubs/memory endpoint" do
      expect(HttpStub::Configurer::Request::Http::Factory).to receive(:get).with("/stubs/memory").and_return(request)

      subject
    end

    it "submits the request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the request as recalling the servers stubs in memory" do
      expect(request_processor).to receive(:submit).with(hash_including(description: "recalling stubs in memory"))

      subject
    end

  end

  describe "#clear_stubs" do

    let(:request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { facade.clear_stubs }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Factory).to receive(:delete).and_return(request)
      allow(request_processor).to receive(:submit)
    end

    it "creates a DELETE request for the /stubs endpoint" do
      expect(HttpStub::Configurer::Request::Http::Factory).to receive(:delete).with("/stubs").and_return(request)

      subject
    end

    it "submits the request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the request as clearing the server stubs" do
      expect(request_processor).to receive(:submit).with(hash_including(description: "clearing stubs"))

      subject
    end

  end

  describe "#clear_scenarios" do

    let(:request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { facade.clear_scenarios }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Factory).to receive(:delete).and_return(request)
      allow(request_processor).to receive(:submit)
    end

    it "creates a DELETE request for the /stubs/scenarios endpoint" do
      expect(HttpStub::Configurer::Request::Http::Factory).to(
        receive(:delete).with("/stubs/scenarios").and_return(request)
      )

      subject
    end

    it "submits the HTTP Stub request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the request as clearing the server scenarios" do
      expect(request_processor).to receive(:submit).with(hash_including(description: "clearing scenarios"))

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
