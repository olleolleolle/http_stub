describe HttpStub::Server::Scenario::Controller do

  let(:scenario_registry) { instance_double(HttpStub::Server::Registry) }
  let(:server_memory)     { instance_double(HttpStub::Server::Memory::Memory, scenario_registry: scenario_registry) }

  let(:request_uri)        { "/some/request/path" }
  let(:request_parameters) { {} }
  let(:session)            { instance_double(HttpStub::Server::Session::Session) }
  let(:request)            do
    instance_double(HttpStub::Server::Request::Request, uri:        request_uri,
                                                        parameters: request_parameters,
                                                        session:    session)
  end
  let(:logger)             { instance_double(Logger) }
  let(:stubs)              { (1..3).map { instance_double(HttpStub::Server::Stub::Stub) } }
  let(:scenario)           { instance_double(HttpStub::Server::Scenario::Scenario, stubs: stubs) }
  let(:activator)          { instance_double(HttpStub::Server::Scenario::Activator).as_null_object }

  let(:controller) { described_class.new(server_memory) }

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

    let(:scenarios) { (1..3).map { |i| HttpStub::Server::ScenarioFixture.create(name: "#{4 - i}") } }

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

        it "returns a response indicating the request was invalid" do
          expect(subject.status).to eql(400)
        end

        it "returns a response whose body includes the scenario name" do
          expect(subject.body.to_s).to include(scenario_name)
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

        it "returns a response indicating the request was invalid" do
          expect(subject.status).to eql(400)
        end

        it "returns a response whose body includes the name of the not found scenario" do
          expect(subject.body.to_s).to include(scenario_name_not_found)
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

end
