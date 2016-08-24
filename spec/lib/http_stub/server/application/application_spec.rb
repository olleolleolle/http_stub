describe HttpStub::Server::Application::Application do
  include Rack::Test::Methods

  let(:response)      { last_response }
  let(:response_body) { response.body.to_s }

  let(:scenario_controller)   { instance_double(HttpStub::Server::Scenario::Controller) }
  let(:stub_controller)       { instance_double(HttpStub::Server::Stub::Controller) }
  let(:stub_match_controller) { instance_double(HttpStub::Server::Stub::Match::Controller) }

  let(:request)         { HttpStub::Server::RequestFixture.create }
  let(:request_factory) { instance_double(HttpStub::Server::Request::Factory, create: request) }

  let(:response_pipeline) { instance_double(HttpStub::Server::Application::ResponsePipeline, process: nil) }

  let(:app) { described_class.new! }

  before(:example) do
    allow(HttpStub::Server::Scenario::Controller).to receive(:new).and_return(scenario_controller)
    allow(HttpStub::Server::Stub::Controller).to receive(:new).and_return(stub_controller)
    allow(HttpStub::Server::Stub::Match::Controller).to receive(:new).and_return(stub_match_controller)
    allow(HttpStub::Server::Request::Factory).to receive(:new).and_return(request_factory)
    allow(HttpStub::Server::Application::ResponsePipeline).to receive(:new).and_return(response_pipeline)
  end

  describe "::configure" do

    let(:args)                { { some_argument_key: "some argument value" } }
    let(:configured_settings) { { setting_1: "value 1", setting_2: "value 2", setting_3: "value 3" } }
    let(:configuration)       do
      instance_double(HttpStub::Server::Application::Configuration, settings: configured_settings)
    end

    subject { described_class.configure(args) }

    before(:example) { allow(HttpStub::Server::Application::Configuration).to receive(:new).and_return(configuration) }

    it "creates application configuration encapsulating the arguments" do
      expect(HttpStub::Server::Application::Configuration).to receive(:new).with(args).and_return(configuration)

      subject
    end

    it "establishes the configured settings on the application" do
      subject

      configured_settings.each { |name, value| expect(described_class.settings.send(name)).to eql(value) }
    end

  end

  describe "session identifer" do

    context "when configured" do

      let(:session_identifier) { { header: :some_session_identifier } }

      before(:example) do
        @original_session_identifier = described_class.settings.session_identifier
        described_class.set :session_identifier, session_identifier
      end

      after(:example) { described_class.set :session_identifier, @original_session_identifier }

      it "creates a request factory with the configuration" do
        expect(HttpStub::Server::Request::Factory).to receive(:new).with(anything, session_identifier)

        issue_a_request
      end

    end

    context "when not configured" do

      it "creates a request factory with a nil configuration" do
        expect(HttpStub::Server::Request::Factory).to receive(:new).with(anything, nil)

        issue_a_request
      end

    end

    def issue_a_request
      get "/http_stub"
    end

  end

  context "when the diagnostics landing page is retrieved" do

    subject { get "/http_stub" }

    it "responds without error" do
      subject

      expect(response.status).to eql(200)
    end

  end

  context "when a stub registration request is received" do

    let(:registration_response) { instance_double(HttpStub::Server::Stub::Response::Base) }

    subject do
      post "/http_stub/stubs", { uri: "/a_path", method: "a method", response: { status: 200, body: "Foo" } }.to_json
    end

    before(:example) { allow(stub_controller).to receive(:register).and_return(registration_response) }

    it "registers the stub via the stub controller" do
      expect(stub_controller).to receive(:register).and_return(registration_response)

      subject
    end

    it "processes the stub controllers response via the response pipeline" do
      expect(response_pipeline).to receive(:process).with(registration_response)

      subject
    end

  end

  context "when a request to list the stubs is received" do

    let(:found_stubs) { [ HttpStub::Server::Stub::Empty::INSTANCE ] }

    subject { get "/http_stub/stubs" }

    it "retrieves the stubs for the current user via the stub controller" do
      expect(stub_controller).to receive(:find_all).with(request).and_return(found_stubs)

      subject
    end

  end

  context "when a request to show a stub is received" do

    let(:stub_id)    { SecureRandom.uuid }
    let(:found_stub) { HttpStub::Server::Stub::Empty::INSTANCE }

    subject { get "/http_stub/stubs/#{stub_id}" }

    it "retrieves the stub for the current user via the stub controller" do
      expect(stub_controller).to receive(:find).with(request, anything).and_return(found_stub)

      subject
    end

  end

  context "when a request to clear the stubs is received" do

    subject { delete "/http_stub/stubs" }

    before(:example) { allow(stub_controller).to receive(:clear) }

    it "clears the stubs for the current user via the stub controller" do
      expect(stub_controller).to receive(:clear).with(request, anything)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  context "when a request to commit the stubs to memory is received" do

    subject { post "/http_stub/stubs/memory" }

    before(:example) { allow(stub_controller).to receive(:remember_state) }

    it "remembers the stubs for the current user via the stub controller" do
      expect(stub_controller).to receive(:remember_state).with(request)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  context "when a request to recall the stubs in memory is received" do

    subject { get "/http_stub/stubs/memory" }

    before(:example) { allow(stub_controller).to receive(:recall_state) }

    it "recalls the stubs for the current user via the stub controller" do
      expect(stub_controller).to receive(:recall_state).with(request)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  context "when a request to list the stub matches is received" do

    let(:found_matches) { [ HttpStub::Server::Stub::Match::MatchFixture.create ] }

    subject { get "/http_stub/stubs/matches" }

    it "retrieves the matches for the current user via the stub match controller" do
      expect(stub_match_controller).to receive(:matches).with(request).and_return(found_matches)

      subject
    end

  end

  context "when a request to retrieve the last match for an endpoint is received" do

    let(:uri)                 { "/some/matched/uri" }
    let(:method)              { "some http method" }
    let(:last_match_response) { instance_double(HttpStub::Server::Stub::Response::Base) }

    subject { get "/http_stub/stubs/matches/last", "uri" => uri, "method" => method }

    before(:example) { allow(stub_match_controller).to receive(:last_match).and_return(last_match_response) }

    it "retrieves the last match for the user via the match result controller" do
      expect(stub_match_controller).to receive(:last_match).with(request, anything)

      subject
    end

    it "processes the match result controllers response via the response pipeline" do
      expect(response_pipeline).to receive(:process).with(last_match_response)

      subject
    end

  end

  context "when a request to list the stub misses is received" do

    let(:found_misses) { [ HttpStub::Server::Stub::Match::MissFixture.create ] }

    subject { get "/http_stub/stubs/misses" }

    it "retrieves the misses for the current user via the stub match controller" do
      expect(stub_match_controller).to receive(:misses).with(request).and_return(found_misses)

      subject
    end

  end

  context "when a scenario registration request is received" do

    let(:registration_response) { instance_double(HttpStub::Server::Stub::Response::Base) }

    before(:example) { allow(scenario_controller).to receive(:register).and_return(registration_response) }

    subject do
      post "/http_stub/scenarios",
           {
             uri: "/a_scenario_path",
             stubs: [ { uri: "/a_path", method: "a method", response: { status: 200, body: "Foo" } } ],
             triggered_scenario_names: [ "some/uri/to/activate" ]
           }.to_json
    end

    it "registers the scenario via the scenario controller" do
      expect(scenario_controller).to receive(:register).and_return(registration_response)

      subject
    end

    it "processes the scenario controllers response via the response pipeline" do
      expect(response_pipeline).to receive(:process).with(registration_response)

      subject
    end

  end

  context "when a request to show a scenario is received" do

    let(:scenario_name)  { "Some scenario name" }
    let(:found_scenario) { HttpStub::Server::Scenario::ScenarioFixture.create }

    subject { get "/http_stub/scenarios?#{URI.encode_www_form(:name => scenario_name)}" }

    it "retrieves the scenario via the scenario controller" do
      expect(scenario_controller).to receive(:find).with(request, anything).and_return(found_scenario)

      subject
    end

  end

  context "when a request to list the scenarios is received" do

    let(:found_scenarios) { [ HttpStub::Server::Scenario::ScenarioFixture.create ] }

    subject { get "/http_stub/scenarios" }

    it "retrieves the scenarios via the scenario controller" do
      expect(scenario_controller).to receive(:find_all).and_return(found_scenarios)

      subject
    end

  end

  context "when a scenario activation request is received" do

    let(:scenario_name)       { "Some scenario name" }
    let(:activation_response) { instance_double(HttpStub::Server::Stub::Response::Base) }

    subject { post "/http_stub/scenarios/activate", name: scenario_name }

    before(:example) { allow(scenario_controller).to receive(:activate).and_return(activation_response) }

    it "activates the scenario via the scenario controller" do
      expect(scenario_controller).to receive(:activate).with(request, anything).and_return(activation_response)

      subject
    end

    it "processes the scenario controllers response via the response pipeline" do
      expect(response_pipeline).to receive(:process).with(activation_response)

      subject
    end

  end

  context "when a request to clear the scenarios has been received" do

    subject { delete "/http_stub/scenarios" }

    before(:example) { allow(scenario_controller).to receive(:clear) }

    it "delegates clearing to the scenario controller" do
      expect(scenario_controller).to receive(:clear).with(anything)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  context "when a request for the diagnostic pages stylesheet has been received" do

    subject { get "/application.css" }

    it "responds without error" do
      subject

      expect(response.status).to eql(200)
    end

  end

  context "when another type of request is received" do

    let(:stub_response) { instance_double(HttpStub::Server::Stub::Response::Base) }

    subject { get "/a_path" }

    before(:example) { allow(stub_controller).to receive(:match).and_return(stub_response) }

    it "attempts to match the request to a stub response via the stub controller" do
      expect(stub_controller).to receive(:match).with(an_instance_of(HttpStub::Server::Request::Request), anything)

      subject
    end

    it "processes the response via the response pipeline" do
      expect(response_pipeline).to receive(:process).with(stub_response)

      subject
    end

  end

  it "disables all standard HTTP security measures to allow stubs full control of responses" do
    expect(app.settings.protection).to eql(false)
  end

  it "disables cross origin support by default" do
    expect(app.settings.cross_origin_support).to eql(false)
  end

end
