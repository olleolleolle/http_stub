describe HttpStub::Server::Status::Controller do

  let(:session_configuration) { instance_double(HttpStub::Server::Session::Configuration) }
  let(:server_memory)         { instance_double(HttpStub::Server::Memory::Memory) }

  let(:controller) { described_class.new(session_configuration, server_memory) }

  describe "#current" do

    let(:current_memory_status) { "Some status" }

    subject { controller.current }

    before(:example) { allow(server_memory).to receive(:status).and_return(current_memory_status) }

    it "returns the current status of the servers memory" do
      expect(subject).to eql(current_memory_status)
    end

  end

  describe "#initialized" do

    subject { controller.initialized }

    before(:example) do
      allow(server_memory).to receive(:initialized!)
      allow(session_configuration).to receive(:default_identifier=)
    end

    it "marks the servers memory as intialized" do
      expect(server_memory).to receive(:initialized!)

      subject
    end

    it "establishes the transactional session as the default session" do
      expect(session_configuration).to(
        receive(:default_identifier=).with(HttpStub::Server::Session::TRANSACTIONAL_SESSION_ID)
      )

      subject
    end

  end

end
