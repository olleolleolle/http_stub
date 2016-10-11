describe HttpStub::Server::Application::Routes::Scenario do
  include_context "http_stub rack application test"

  let(:scenario_controller) { instance_double(HttpStub::Server::Scenario::Controller) }

  before(:example) { allow(HttpStub::Server::Scenario::Controller).to receive(:new).and_return(scenario_controller) }

  context "when a scenario registration request is received" do

    let(:payload) do
      {
        uri: "/a_scenario_path",
        stubs: [ { uri: "/a_path", method: "a method", response: { status: 200, body: "Foo" } } ],
        triggered_scenario_names: [ "some/uri/to/activate" ]
      }.to_json
    end
    let(:registration_response) { instance_double(HttpStub::Server::Stub::Response::Base) }

    before(:example) do
      allow(request).to receive(:body).and_return(payload)
      allow(scenario_controller).to receive(:register).and_return(registration_response)
    end

    subject { post "/http_stub/scenarios" }

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
    let(:found_scenario) { HttpStub::Server::ScenarioFixture.create }

    subject { get "/http_stub/scenarios" }

    before(:example) { allow(request).to receive(:parameters).and_return(name: scenario_name) }

    it "retrieves the scenario via the scenario controller" do
      expect(scenario_controller).to receive(:find).with(request, anything).and_return(found_scenario)

      subject
    end

  end

  context "when a request to list the scenarios is received" do

    let(:found_scenarios) { [ HttpStub::Server::ScenarioFixture.create ] }

    subject { get "/http_stub/scenarios" }

    it "retrieves the scenarios via the scenario controller" do
      expect(scenario_controller).to receive(:find_all).and_return(found_scenarios)

      subject
    end

  end

  context "when a request to active scenarios is received" do

    let(:scenario_names)      { (1..3).map { |i| "scenario name #{i}" } }
    let(:activation_response) { instance_double(HttpStub::Server::Stub::Response::Base) }

    subject { post "/http_stub/scenarios/activate" }

    before(:example) do
      allow(request).to receive(:parameters).and_return(names: scenario_names)
      allow(scenario_controller).to receive(:activate).and_return(activation_response)
    end

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

end
