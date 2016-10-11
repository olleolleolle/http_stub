describe HttpStub::Server::Scenario::Controller do

  let(:scenario_registry) { instance_double(HttpStub::Server::Registry) }
  let(:server_memory)     { instance_double(HttpStub::Server::Memory::Memory, scenarios: scenario_registry) }

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
  let(:activator)          { instance_double(HttpStub::Server::Scenario::Activator).as_null_object }

  let(:controller) { described_class.new(server_memory) }

  describe "#register" do

    subject { controller.register(request, logger) }

    before(:example) do
      allow(HttpStub::Server::Scenario::Parser).to receive(:parse).and_return(payload)
      allow(HttpStub::Server::Scenario).to receive(:create).and_return(scenario)
      allow(scenario_registry).to receive(:add)
    end

    it "parses the payload from the request" do
      expect(HttpStub::Server::Scenario::Parser).to receive(:parse).with(request).and_return(payload)

      subject
    end

    it "creates a scenario with the parsed payload" do
      expect(HttpStub::Server::Scenario).to receive(:create).with(payload).and_return(scenario)

      subject
    end

    it "adds the created scenario to the servers scenario registry with the provided logger" do
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

    let(:scenarios) { (1..3).map { |i| HttpStub::Server::ScenarioFixture.create("#{4 - i}") } }

    subject { controller.find_all }

    before(:example) { allow(scenario_registry).to receive(:all).and_return(scenarios) }

    it "retrieves all scenarios from the servers scenario registry" do
      expect(scenario_registry).to receive(:all)

      subject
    end

    it "returns the scenarios sorted by name" do
      expect(subject).to eql(scenarios.reverse)
    end

  end

  describe "#activate" do

    subject { controller.activate(request, logger) }

    context "when a scenario name is provided" do

      let(:scenario_name)      { "some scenario name" }
      let(:request_parameters) { { name: scenario_name } }

      it "delegates to the users session to activate the scenario with the parameterized name" do
        expect(session).to receive(:activate_scenario!).with(scenario_name, logger)

        subject
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

    context "when scenario names are provided" do

      let(:scenario_names)     { (1..3).map { |i| "scenario name #{i}" } }
      let(:request_parameters) { { names: scenario_names } }

      it "delegates to the users session to activate the scenarios with the parameterized names" do
        scenario_names.each do |scenario_name|
          expect(session).to receive(:activate_scenario!).with(scenario_name, logger)
        end

        subject
      end

      describe "when a scenario is not found" do

        let(:scenario_name_not_found) { scenario_names[1] }

        before(:example) do
          allow(session).to receive(:activate_scenario!)
          allow(session).to(
            receive(:activate_scenario!).with(scenario_name_not_found, anything)
              .and_raise(HttpStub::Server::Scenario::NotFoundError, scenario_name_not_found)
          )
        end

        it "returns a not found response" do
          expect(subject).to eql(HttpStub::Server::Response::NOT_FOUND)
        end

      end

    end

    describe "when all scenarios are successfully activated" do

      let(:request_parameters) { { name: "some scenario name" } }

      before(:example) { allow(session).to receive(:activate_scenario!) }

      it "returns an ok response" do
        expect(subject).to eql(HttpStub::Server::Response::OK)
      end

    end

  end

  describe "#clear" do

    subject { controller.clear(logger) }

    it "clears the servers scenario registry" do
      expect(scenario_registry).to receive(:clear).with(logger)

      subject
    end

  end

end
