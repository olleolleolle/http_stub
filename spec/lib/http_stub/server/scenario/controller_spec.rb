describe HttpStub::Server::Scenario::Controller do

  let(:request_uri)       { "/some/request/path" }
  let(:request)           { instance_double(HttpStub::Server::Request::Request, uri: request_uri) }
  let(:logger)            { instance_double(Logger) }
  let(:payload)           { HttpStub::ScenarioFixture.new.server_payload }
  let(:stubs)             { (1..3).map { instance_double(HttpStub::Server::Stub::Stub) } }
  let(:scenario)          { instance_double(HttpStub::Server::Scenario::Scenario, stubs: stubs) }
  let(:scenario_registry) { instance_double(HttpStub::Server::Registry).as_null_object }
  let(:stub_registry)     { instance_double(HttpStub::Server::Stub::Registry).as_null_object }
  let(:activator)         { instance_double(HttpStub::Server::Scenario::Activator).as_null_object }

  let(:controller) { HttpStub::Server::Scenario::Controller.new(scenario_registry, stub_registry) }

  before(:example) do
    allow(HttpStub::Server::Scenario::Activator).to receive(:new).and_return(activator)
    allow(HttpStub::Server::Scenario::Parser).to receive(:parse).and_return(payload)
    allow(HttpStub::Server::Scenario).to receive(:create).and_return(scenario)
  end

  describe "#register" do

    subject { controller.register(request, logger) }

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

  describe "#activate" do

    let(:scenario_name) { "Some Scenario Name" }

    subject { controller.activate(scenario_name, logger) }

    it "finds a scenario whose name matches the provided name" do
      expect(scenario_registry).to receive(:find).with(scenario_name, logger)

      subject
    end

    describe "when a scenario is found" do

      before(:example) { allow(scenario_registry).to receive(:find).and_return(scenario) }

      it "activates the scenario via the activator" do
        expect(activator).to receive(:activate).with(scenario, logger)

        subject
      end

      it "returns an ok response" do
        expect(subject).to eql(HttpStub::Server::Response::OK)
      end

    end

    describe "when no scenario is found" do

      before(:example) { allow(scenario_registry).to receive(:find).and_return(nil) }

      it "does not add a stub to the registry" do
        expect(stub_registry).not_to receive(:concat)

        subject
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
