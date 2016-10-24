describe HttpStub::Configurer::Server::Facade do

  let(:configuration) { double(HttpStub::Configurer::Server::Configuration) }

  let(:request_processor) { instance_double(HttpStub::Configurer::Server::RequestProcessor) }

  let(:facade) { HttpStub::Configurer::Server::Facade.new(configuration) }

  before(:example) do
    allow(HttpStub::Configurer::Server::RequestProcessor).to receive(:new).and_return(request_processor)
  end
  
  it "creates a request processor with the provided configuration" do
    expect(HttpStub::Configurer::Server::RequestProcessor).to receive(:new).with(configuration)

    facade
  end

  describe "#initialize_server" do

    let(:request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { facade.initialize_server }

    before(:example) do
      allow(request_processor).to receive(:flush!)
      allow(HttpStub::Configurer::Request::Http::Factory).to receive(:post).and_return(request)
      allow(request_processor).to receive(:submit)
    end

    it "causes the request processor to flush its requests" do
      expect(request_processor).to receive(:flush!)

      subject
    end

    it "creates a POST request for the initialized status endpoint" do
      expect(HttpStub::Configurer::Request::Http::Factory).to(
        receive(:post).with("status/initialized").and_return(request)
      )

      subject
    end

    it "submits the HTTP Stub request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the request as marking the server as initialized" do
      expect(request_processor).to receive(:submit).with(hash_including(description: "marking server as initialized"))

      subject
    end

  end

  describe "#server_has_started" do

    subject { facade.server_has_started }

    it "informs the request processor to disable buffering requests" do
      expect(request_processor).to receive(:disable_buffering!)

      subject
    end

  end

  describe "#reset" do

    let(:request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { facade.reset }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Factory).to receive(:delete).and_return(request)
      allow(request_processor).to receive(:submit)
    end

    it "creates a DELETE request for the memory endpoint" do
      expect(HttpStub::Configurer::Request::Http::Factory).to receive(:delete).with("memory").and_return(request)

      subject
    end

    it "submits the HTTP Stub request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the request as resetting the server" do
      expect(request_processor).to receive(:submit).with(hash_including(description: "resetting server"))

      subject
    end

  end

  describe "#define_scenario" do

    let(:scenario_description) { "some scenario description" }
    let(:scenario)             { instance_double(HttpStub::Configurer::Request::Scenario, to_s: scenario_description) }

    let(:request) { instance_double(HttpStub::Configurer::Request::Http::Multipart) }

    subject { facade.define_scenario(scenario) }

    before(:example) do
      allow(request_processor).to receive(:submit)
      allow(HttpStub::Configurer::Request::Http::Factory).to receive(:multipart).and_return(request)
    end

    it "creates a multipart request to the scenarios endpoint" do
      expect(HttpStub::Configurer::Request::Http::Factory).to receive(:multipart).with("scenarios", anything)

      subject
    end

    it "creates a multipart request with the provided scenario" do
      expect(HttpStub::Configurer::Request::Http::Factory).to receive(:multipart).with(anything, scenario)

      subject
    end

    it "submits the request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the scenario via its string representation" do
      expect(request_processor).to(
        receive(:submit).with(hash_including(description: "registering scenario '#{scenario_description}'"))
      )

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

    it "creates a DELETE request for the scenarios endpoint" do
      expect(HttpStub::Configurer::Request::Http::Factory).to receive(:delete).with("scenarios").and_return(request)

      subject
    end

    it "submits the HTTP Stub request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the request as clearing the servers scenarios" do
      expect(request_processor).to receive(:submit).with(hash_including(description: "clearing scenarios"))

      subject
    end

  end

  describe "#create_session_facade" do

    let(:session_id) { "some session id" }

    let(:session_facade) { instance_double(HttpStub::Configurer::Server::SessionFacade) }

    subject { facade.create_session_facade(session_id) }

    before(:example) { allow(HttpStub::Configurer::Server::SessionFacade).to receive(:new).and_return(session_facade) }

    it "creates a session facade for the provided session" do
      expect(HttpStub::Configurer::Server::SessionFacade).to receive(:new).with(session_id, anything)

      subject

    end

    it "creates a session facade that processes requests the server facades request processor" do
      expect(HttpStub::Configurer::Server::SessionFacade).to receive(:new).with(anything, request_processor)

      subject
    end

    it "returns the created session facade" do
      expect(subject).to eql(session_facade)
    end

  end

  describe "#clear_sessions" do

    let(:request) { instance_double(HttpStub::Configurer::Request::Http::Basic) }

    subject { facade.clear_sessions }

    before(:example) do
      allow(HttpStub::Configurer::Request::Http::Factory).to receive(:delete).and_return(request)
      allow(request_processor).to receive(:submit)
    end

    it "creates a DELETE request for the sessions endpoint" do
      expect(HttpStub::Configurer::Request::Http::Factory).to receive(:delete).with("sessions").and_return(request)

      subject
    end

    it "submits the HTTP Stub request via the request processor" do
      expect(request_processor).to receive(:submit).with(hash_including(request: request))

      subject
    end

    it "describes the request as clearing the servers sessions" do
      expect(request_processor).to receive(:submit).with(hash_including(description: "clearing sessions"))

      subject
    end

  end

end
