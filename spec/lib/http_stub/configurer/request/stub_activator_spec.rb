describe HttpStub::Configurer::Request::StubActivator do

  let(:activation_uri) { "some/activation/uri" }
  let(:stub)           { instance_double(HttpStub::Configurer::Request::Stub) }

  let(:stub_activator) { HttpStub::Configurer::Request::StubActivator.new(activation_uri: activation_uri, stub: stub) }

  describe "#payload" do

    let(:stub_payload) { { stub_payload_key: "stub payload value " } }

    subject { stub_activator.payload }

    before(:example) { allow(stub).to receive(:payload).and_return(stub_payload) }

    it "returns a hash containing the activation uri" do
      expect(subject).to include(activation_uri: activation_uri)
    end

    it "returns a hash containing the stub payload" do
      expect(subject).to include(stub_payload)
    end

  end

  describe "#response_files" do

    it "delegates to the stub" do
      stub_response_files = (1..3).each { instance_double(HttpStub::Configurer::Request::StubResponseFile) }
      allow(stub).to receive(:response_files).and_return(stub_response_files)

      expect(stub_activator.response_files).to eql(stub_response_files)
    end

  end

  describe "#to_s" do

    it "returns the activation uri" do
      expect(stub_activator.to_s).to eql(activation_uri)
    end

  end

end
