describe HttpStub::Server::Memory::Controller do

  let(:server_memory) { instance_double(HttpStub::Server::Memory::Memory) }

  let(:controller) { described_class.new(server_memory) }

  describe "#find_stubs" do

    let(:memorized_stubs) { (1..3).map { instance_double(HttpStub::Server::Stub::Stub) } }

    subject { controller.find_stubs }

    before(:example) { allow(server_memory).to receive(:stubs).and_return(memorized_stubs) }

    it "returns the stubs within the servers memory" do
      expect(subject).to eql(memorized_stubs)
    end

  end

end
