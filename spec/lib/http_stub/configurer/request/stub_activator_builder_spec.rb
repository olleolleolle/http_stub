describe HttpStub::Configurer::Request::StubActivatorBuilder do

  let(:stub_fixture) { HttpStub::StubFixture.new }

  let(:response_defaults) { {} }
  let(:activation_uri)    { "/some/activation/uri" }
  let(:scenario)          { instance_double(HttpStub::Configurer::Request::Scenario) }
  let(:scenario_builder) do
    instance_double(HttpStub::Configurer::Request::ScenarioBuilder, build: scenario, add_stub!: nil)
  end
  let(:stub_builder)      { instance_double(HttpStub::Configurer::Request::StubBuilder) }

  let(:builder) { HttpStub::Configurer::Request::StubActivatorBuilder.new(response_defaults) }

  before(:example) do
    allow(HttpStub::Configurer::Request::ScenarioBuilder).to receive(:new).and_return(scenario_builder)
    allow(HttpStub::Configurer::Request::StubBuilder).to receive(:new).and_return(stub_builder)
  end

  describe "#on" do

    subject { builder.on(activation_uri) }

    it "creates a scenario builder with the response defaults and activation uri" do
      expect(HttpStub::Configurer::Request::ScenarioBuilder).to receive(:new).with(response_defaults, activation_uri)

      subject
    end

    it "creates a stub builder with the response defaults" do
      expect(HttpStub::Configurer::Request::StubBuilder).to receive(:new).with(response_defaults)

      subject
    end

    it "adds the stub builder to the scenario builder" do
      expect(scenario_builder).to receive(:add_stub!).with(stub_builder)

      subject
    end

  end

  describe "#match_requests" do

    let(:request_payload) { stub_fixture.request.configurer_payload }

    before(:example) { builder.on(activation_uri) }

    it "delegates to a stub builder" do
      expect(stub_builder).to receive(:match_requests).with(stub_fixture.request.uri, request_payload)

      builder.match_requests(stub_fixture.request.uri, request_payload)
    end

  end

  describe "#respond_with" do

    let(:response_payload) { stub_fixture.response.configurer_payload }

    before(:example) { builder.on(activation_uri) }

    it "delegates to a stub builder" do
      expect(stub_builder).to receive(:respond_with).with(response_payload)

      builder.respond_with(response_payload)
    end

  end

  describe "#trigger" do

    before(:example) { builder.on(activation_uri) }

    context "when one triggered stub is provided" do

      let(:trigger_builder) { instance_double(HttpStub::Configurer::Request::StubBuilder) }

      it "delegates to a stub builder" do
        expect(stub_builder).to receive(:trigger).with(trigger_builder)

        builder.trigger(trigger_builder)
      end

    end

    context "when many triggered stubs are provided" do

      let(:trigger_builders) { (1..3).map { instance_double(HttpStub::Configurer::Request::StubBuilder) } }

      it "delegates to a stub builder" do
        expect(stub_builder).to receive(:trigger).with(trigger_builders)

        builder.trigger(trigger_builders)
      end

    end

  end

  describe "#build" do

    subject { builder.build }

    before(:example) { builder.on(activation_uri) }

    it "builds a scenario" do
      expect(scenario_builder).to receive(:build)

      subject
    end

    it "returns the built scenario" do
      expect(subject).to eql(scenario)
    end

  end

end
