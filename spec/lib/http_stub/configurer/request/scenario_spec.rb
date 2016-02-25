describe HttpStub::Configurer::Request::Scenario do

  let(:name)                     { "Some scenario name" }
  let(:stubs)                    { (1..3).map { instance_double(HttpStub::Configurer::Request::Stub) } }
  let(:triggered_scenario_names) { (1..3).map { |i| "Triggered scenario name #{i}" } }

  let(:scenario) do
    HttpStub::Configurer::Request::Scenario.new(
      name: name, stubs: stubs, triggered_scenario_names: triggered_scenario_names
    )
  end

  describe "#payload" do

    let(:stub_payloads) { stubs.each_with_index.map { |_stub, i| { stub_payload_key: "stub payload value #{i}" } } }

    subject { scenario.payload }

    before(:example) do
      stubs.zip(stub_payloads).each { |stub, payload| allow(stub).to receive(:payload).and_return(payload) }
    end

    it "returns a hash containing the scenario's name" do
      expect(subject).to include(name: name)
    end

    it "returns a hash containing the stub payloads" do
      expect(subject).to include(stubs: stub_payloads)
    end

    it "returns a hash containing the uris to activate" do
      expect(subject).to include(triggered_scenario_names: triggered_scenario_names)
    end

  end

  describe "#response_files" do

    let(:stub_response_files) do
      stubs.map { (1..3).map { instance_double(HttpStub::Configurer::Request::StubResponseFile) } }
    end

    subject { scenario.response_files }

    before(:example) do
      stubs.zip(stub_response_files).each { |stub, files| allow(stub).to receive(:response_files).and_return(files) }
    end

    it "delegates to the stubs" do
      stubs.zip(stub_response_files).each { |stub, files| expect(stub).to receive(:response_files).and_return(files) }

      subject
    end

    it "returns the accummulation of all stub files" do
      expect(subject).to eql(stub_response_files.flatten)
    end

  end

  describe "#to_s" do

    it "returns the scenario's name" do
      expect(scenario.to_s).to eql(name)
    end

  end

end
