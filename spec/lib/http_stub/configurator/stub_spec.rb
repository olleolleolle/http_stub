describe HttpStub::Configurator::Stub do

  describe "::create" do

    let(:name)           { "some stub name" }
    let(:block_verifier) { double("BlockVerifier") }
    let(:block)          { lambda { block_verifier.verify } }

    subject { described_class.create(name, &block) }

    it "creates a stub with the provided arguments" do
      expect(HttpStub::Configurator::Stub::Stub).to receive(:new).with(name).and_yield
      expect(block_verifier).to receive(:verify)

      subject
    end

    it "returns the created stub" do
      created_stub = instance_double(HttpStub::Configurator::Stub::Stub)
      allow(HttpStub::Configurator::Stub::Stub).to receive(:new).and_return(created_stub)

      expect(subject).to eql(created_stub)
    end

  end

end
