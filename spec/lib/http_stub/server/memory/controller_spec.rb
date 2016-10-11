describe HttpStub::Server::Memory::Controller do

  let(:session_configuration) { instance_double(HttpStub::Server::Session::Configuration) }
  let(:server_memory)         { instance_double(HttpStub::Server::Memory::Memory) }

  let(:controller) { described_class.new(session_configuration, server_memory) }

  describe "#find_stubs" do

    let(:memorized_stubs) { (1..3).map { instance_double(HttpStub::Server::Stub::Stub) } }

    subject { controller.find_stubs }

    before(:example) { allow(server_memory).to receive(:stubs).and_return(memorized_stubs) }

    it "returns the stubs within the servers memory" do
      expect(subject).to eql(memorized_stubs)
    end

  end

  describe "#reset" do

    let(:logger) { instance_double(Logger) }

    subject { controller.reset(logger) }

    before(:example) do
      allow(session_configuration).to receive(:reset)
      allow(server_memory).to receive(:reset)
    end

    it "resets the servers session configuration" do
      expect(session_configuration).to receive(:reset)

      subject
    end

    it "resets the servers memory providing the logger" do
      expect(server_memory).to receive(:reset).with(logger)

      subject
    end

  end

end
