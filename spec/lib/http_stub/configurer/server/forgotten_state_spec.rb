describe HttpStub::Configurer::Server::ForgottenState do

  let(:command)         { instance_double(HttpStub::Configurer::Server::Command) }

  let(:forgotten_state) { HttpStub::Configurer::Server::ForgottenState.new }

  describe "#<<" do

    it "immediately executes the provided command" do
      expect(command).to receive(:execute)

      forgotten_state << command
    end

  end

end
