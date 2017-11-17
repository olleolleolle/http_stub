describe HttpStub::Configurator::State do

  let(:port) { 8888 }

  let(:state) { described_class.new }

  before(:example) { state.port = port }

  describe "#external_base_uri" do

    subject { state.external_base_uri }

    before(:example) { @initial_base_uri = ENV["STUB_EXTERNAL_BASE_URI"] }

    after(:example) { ENV["STUB_EXTERNAL_BASE_URI"] = @initial_base_uri }

    context "when the STUB_EXTERNAL_BASE_URI environment variable is established" do

      let(:base_uri) { "http://some/base/uri" }

      before(:example) { ENV["STUB_EXTERNAL_BASE_URI"] = base_uri }

      after(:example) { ENV["STUB_EXTERNAL_BASE_URI"] = @initial_base_uri }

      it "returns the environments variables value" do
        expect(subject).to eql(base_uri)
      end

    end

    context "when the STUB_EXTERNAL_BASE_URI environment variable is not established" do

      before(:example) { ENV["STUB_EXTERNAL_BASE_URI"] = nil }

      it "returns a local uri containing the port" do
        expect(subject).to eql("http://localhost:#{port}")
      end

    end

  end

  describe "#add_scenario" do

    let(:scenario_hash) { { some_scenario_key: "some value" } }
    let(:scenario)      { instance_double(HttpStub::Configurator::Scenario, to_hash: scenario_hash) }

    subject { state.add_scenario(scenario) }

    it "adds the hash representation of the scenario" do
      subject

      expect(state.scenario_hashes).to include(scenario_hash)
    end

  end

  describe "#add_stub" do

    let(:stub_hash) { { some_stub_key: "some value" } }
    let(:the_stub)  { instance_double(HttpStub::Configurator::Stub::Stub, to_hash: stub_hash) }

    subject { state.add_stub(the_stub) }

    it "adds the hash representation of the stub" do
      subject

      expect(state.stub_hashes).to include(stub_hash)
    end

  end

  describe "#application_settings" do

    subject { state.application_settings }

    it "includes the configured port" do
      expect(subject).to include(port: port)
    end

    context "when a session identifier is provided" do

      let(:session_identifier) { { parameter: "some_session_identifier" } }

      before(:example) { state.session_identifier = session_identifier }

      it "includes the session identifier" do
        expect(subject).to include(session_identifier: session_identifier)
      end

    end

    context "when cross-origin support is enabled" do

      before(:example) { state.enable(:cross_origin_support) }

      it "indicates cross-origin support is enabled" do
        expect(subject).to include(cross_origin_support: true)
      end

    end

    context "when cross-origin support is disabled" do

      it "indicates cross-origin support is disabled" do
        expect(subject).to include(cross_origin_support: false)
      end

    end

  end

end
