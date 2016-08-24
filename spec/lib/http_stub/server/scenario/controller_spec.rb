describe HttpStub::Server::Scenario::Controller do

  let(:request_uri)        { "/some/request/path" }
  let(:request_parameters) { {} }
  let(:session)            { instance_double(HttpStub::Server::Session::Session) }
  let(:request)            do
    instance_double(HttpStub::Server::Request::Request, uri:        request_uri,
                                                        parameters: request_parameters,
                                                        session:    session)
  end
  let(:logger)             { instance_double(Logger) }
  let(:payload)            { HttpStub::ScenarioFixture.new.server_payload }
  let(:stubs)              { (1..3).map { instance_double(HttpStub::Server::Stub::Stub) } }
  let(:scenario)           { instance_double(HttpStub::Server::Scenario::Scenario, stubs: stubs) }
  let(:scenario_registry)  { instance_double(HttpStub::Server::Registry).as_null_object }
  let(:activator)          { instance_double(HttpStub::Server::Scenario::Activator).as_null_object }

  let(:controller) { HttpStub::Server::Scenario::Controller.new(scenario_registry) }

  describe "#register" do

    subject { controller.register(request, logger) }

    before(:example) do
      allow(HttpStub::Server::Scenario::Parser).to receive(:parse).and_return(payload)
      allow(HttpStub::Server::Scenario).to receive(:create).and_return(scenario)
    end

    it "parses the payload from the request" do
      expect(HttpStub::Server::Scenario::Parser).to receive(:parse).with(request).and_return(payload)

      subject
    end

    it "creates a scenario with the parsed payload" do
      expect(HttpStub::Server::Scenario).to receive(:create).with(payload).and_return(scenario)

      subject
    end

    it "adds the created scenario to the scenario registry with the provided logger" do
      expect(scenario_registry).to receive(:add).with(scenario, logger)

      subject
    end

    it "returns an ok response" do
      expect(subject).to eql(HttpStub::Server::Response::OK)
    end

  end

  describe "#find" do

    let(:name)               { URI.encode_www_form_component("Some scenario name") }
    let(:request_parameters) { { name: name } }

    subject { controller.find(request, logger) }

    before(:example) { allow(scenario_registry).to receive(:find).and_return(scenario) }

    it "finds a scenario matching the parameterized name via the registry" do
      expect(scenario_registry).to receive(:find).with(URI.decode_www_form_component("Some scenario name"), anything)

      subject
    end

    it "finds the scenario using the provided logger" do
      expect(scenario_registry).to receive(:find).with(anything, logger)

      subject
    end

    it "returns the found scenario" do
      expect(subject).to eql(scenario)
    end

  end

  describe "#find_all" do

    let(:scenarios) { (1..3).map { |i| HttpStub::Server::Scenario::ScenarioFixture.create("#{4 - i}") } }

    subject { controller.find_all }

    before(:example) { allow(scenario_registry).to receive(:all).and_return(scenarios) }

    it "retrieves all scenarios from the registry" do
      expect(scenario_registry).to receive(:all)

      subject
    end

    it "returns the scenarios sorted by name" do
      expect(subject).to eql(scenarios.reverse)
    end

  end

  describe "#activate" do

    let(:scenario_name)      { "Some Scenario Name" }
    let(:request_parameters) { { name: scenario_name } }

    subject { controller.activate(request, logger) }

    it "delegates to the users session to activate the scenario with the parameterized name" do
      expect(session).to receive(:activate_scenario!).with(scenario_name, logger)

      subject
    end

    describe "when the scenario is successfully activated" do

      before(:example) { allow(session).to receive(:activate_scenario!).and_return(scenario) }

      it "returns an ok response" do
        expect(subject).to eql(HttpStub::Server::Response::OK)
      end

    end

    describe "when the scenario is not found" do

      before(:example) do
        allow(session).to(
          receive(:activate_scenario!).and_raise(HttpStub::Server::Scenario::NotFoundError, scenario_name)
        )
      end

      it "returns a not found response" do
        expect(subject).to eql(HttpStub::Server::Response::NOT_FOUND)
      end

    end

  end

  describe "#clear" do

    subject { controller.clear(logger) }

    it "clears the scenario registry" do
      expect(scenario_registry).to receive(:clear).with(logger)

      subject
    end

  end

end
