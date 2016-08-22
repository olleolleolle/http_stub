describe HttpStub::Configurer::Request::Triggers do

  let(:scenario_names) { (1..3).map { |i| "Some scenario #{i}" } }
  let(:stubs)          { (1..3).map { instance_double(HttpStub::Configurer::Request::Stub) } }

  let(:triggers) { HttpStub::Configurer::Request::Triggers.new(scenario_names: scenario_names, stubs: stubs) }

  describe "#response_files" do

    let(:stubs)                   do
      response_files_per_stub.map do |response_files|
        instance_double(HttpStub::Configurer::Request::Stub, response_files: response_files)
      end
    end

    subject { triggers.response_files }

    context "when many stubs contains response files" do

      let(:response_files_per_stub) do
        (1..3).map { (1..3).map { HttpStub::Configurer::Request::StubResponseFile } }
      end

      it "returns all the response files" do
        expect(subject).to eql(response_files_per_stub.flatten)
      end

    end

    context "when one stub contains response files" do

      let(:response_files)          { (1..3).map { HttpStub::Configurer::Request::StubResponseFile } }
      let(:response_files_per_stub) { (1..3).map { |i| i % 2 == 0 ? response_files : [] } }

      it "returns the response files" do
        expect(subject).to eql(response_files)
      end

    end

    context "when no stubs contain response files" do

      let(:response_files_per_stub) { (1..3).map { [] } }

      it "returns an empty array" do
        expect(subject).to eql([])
      end

    end

  end

  describe "#payload" do

    let(:stub_payloads) { stubs.each_with_index.map { |i| "Stub payload #{i}" } }

    subject { triggers.payload }

    before(:example) do
      stubs.zip(stub_payloads).each { |stub, payload| allow(stub).to receive(:payload).and_return(payload) }
    end

    context "when scenario names are provided" do

      it "has a scenario names entry containing the names" do
        expect(subject).to include(scenario_names: scenario_names)
      end

    end

    context "when no scenario names are provided" do

      let(:scenario_names) { [] }

      it "has an scenario names entry that is empty" do
        expect(subject).to include(scenario_names: [])
      end

    end

    context "when stubs are provided" do

      it "has a stubs entry containing the payload of the stubs" do
        expect(subject).to include(stubs: stub_payloads)
      end

    end

    context "when stub are not provided" do

      let(:stubs) { [] }

      it "has a stubs entry that is empty" do
        expect(subject).to include(stubs: [])
      end

    end

  end

end
