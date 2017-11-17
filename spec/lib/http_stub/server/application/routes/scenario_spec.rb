describe HttpStub::Server::Application::Routes::Scenario do
  include_context "http_stub rack application test"

  let(:scenario_controller) { instance_double(HttpStub::Server::Scenario::Controller) }

  before(:example) { allow(HttpStub::Server::Scenario::Controller).to receive(:new).and_return(scenario_controller) }

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

  context "when a request to activate a scenario is received" do

    let(:scenario_names)      { (1..3).map { |i| "scenario name #{i}" } }
    let(:activation_response) { HttpStub::Server::Stub::ResponseFixture.create }

    subject { post "/http_stub/scenarios/activate" }

    before(:example) do
      allow(request).to receive(:parameters).and_return(names: scenario_names)
      allow(scenario_controller).to receive(:activate).and_return(activation_response)
    end

    it "activates the scenario via the scenario controller" do
      expect(scenario_controller).to receive(:activate).with(request, anything).and_return(activation_response)

      subject
    end

    it "serves the scenario controllers response" do
      expect(activation_response).to receive(:serve_on).with(an_instance_of(app_class))

      subject
    end

  end

end
