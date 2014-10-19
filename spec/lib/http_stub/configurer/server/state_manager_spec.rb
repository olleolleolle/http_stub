describe HttpStub::Configurer::Server::StateManager do

  let(:command_processor) { instance_double(HttpStub::Configurer::Server::CommandProcessor) }

  let(:configurer)        { double(HttpStub::Configurer) }
  let(:remembered_state)  { instance_double(HttpStub::Configurer::Server::RememberedState) }
  let(:forgotten_state)   { instance_double(HttpStub::Configurer::Server::ForgottenState) }
  let(:state_manager)     { HttpStub::Configurer::Server::StateManager.new(configurer) }

  before(:example) do
    allow(HttpStub::Configurer::Server::CommandProcessor).to receive(:new).and_return(command_processor)
    allow(HttpStub::Configurer::Server::RememberedState).to receive(:new).and_return(remembered_state)
    allow(HttpStub::Configurer::Server::ForgottenState).to receive(:new).and_return(forgotten_state)
  end

  describe "constructor" do

    it "creates a Command Processor for the configurer" do
      expect(HttpStub::Configurer::Server::CommandProcessor).to receive(:new).with(configurer)

      state_manager
    end

  end

  describe "#add" do

    let(:args) { { some_arg_key: "some arg value" } }

    subject { state_manager.add(args) }

    shared_examples_for "adding a command to the servers state" do |state_description|

      let(:command) { instance_double(HttpStub::Configurer::Server::Command) }

      before(:each) { allow(current_state).to receive(:<<) }

      it "creates a command for the provided arguments" do
        expect(HttpStub::Configurer::Server::Command).to receive(:new).with(hash_including(args)).and_return(command)

        subject
      end

      it "adds the configurers command processor to the command" do
        expect(HttpStub::Configurer::Server::Command).to(
          receive(:new).with(hash_including(processor: command_processor))
        ).and_return(command)

        subject
      end

      it "adds the created command to the servers #{state_description}" do
        allow(HttpStub::Configurer::Server::Command).to receive(:new).and_return(command)
        expect(current_state).to receive(:<<).with(command)

        subject
      end

    end

    context "when state is not remembered" do

      let(:current_state) { remembered_state }

      it_behaves_like "adding a command to the servers state", "remembered state"

    end

    context "when state is remembered" do

      let(:current_state) { forgotten_state }

      before(:example) { state_manager.remember }

      it_behaves_like "adding a command to the servers state", "forgotten state"

    end

  end

  describe "#flush_pending_state" do

    it "asks the remembered state to restore itself" do
      expect(remembered_state).to receive(:recall)

      state_manager.flush_pending_state
    end

  end

  describe "#recall" do

    let(:command)        { instance_double(HttpStub::Configurer::Server::Command) }
    let(:filtered_state) { instance_double(HttpStub::Configurer::Server::RememberedState) }

    subject { state_manager.recall }

    before(:example) do
      allow(remembered_state).to receive(:filter).and_return(filtered_state)
      allow(filtered_state).to receive(:recall)
    end

    it "filters the remembered state to retrieve those commands that are resetable" do
      allow(remembered_state).to receive(:filter).and_yield(command).and_return(filtered_state)
      expect(command).to receive(:resetable?)

      subject
    end

    it "asks the filtered remembered state to restore itself" do
      expect(filtered_state).to receive(:recall)

      subject
    end

  end

end
