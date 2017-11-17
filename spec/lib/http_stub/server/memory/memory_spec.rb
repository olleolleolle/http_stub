describe HttpStub::Server::Memory::Memory do

  let(:loaded_scenarios) { HttpStub::Server::ScenarioFixture.many }
  let(:loaded_stubs)     { HttpStub::Server::StubFixture.many }

  let(:configurator_state) { HttpStub::Configurator::State.new }

  let(:initial_state) do
    instance_double(HttpStub::Server::Memory::InitialState, load_scenarios: loaded_scenarios, load_stubs: loaded_stubs)
  end

  let(:memory) { described_class.new(configurator_state) }

  before(:example) { expect(HttpStub::Server::Memory::InitialState).to receive(:new).and_return(initial_state) }

  describe "#scenario_registry" do

    subject { memory.scenario_registry }

    it "returns a scenario registry" do
      expect(subject).to be_an_instance_of(HttpStub::Server::Scenario::Registry)
    end

    it "contains the loaded scenarios" do
      expect(subject.all.map(&:name)).to contain_exactly(*loaded_scenarios.map(&:name))
    end

  end

  describe "#stubs" do

    subject { memory.stubs }

    it "contains the loaded stubs" do
      expect(subject).to eql(loaded_stubs)
    end

  end

  describe "#session_registry" do

    let(:logger) { HttpStub::Server::SilentLogger }

    subject { memory.session_registry }

    it "returns a session registry" do
      expect(subject).to be_an_instance_of(HttpStub::Server::Session::Registry)
    end

    it "contains the loaded scenarios" do
      loaded_scenarios.each do |scenario|
        expect { obtain_session.activate_scenario!(scenario.name, logger) }.to_not raise_error
      end
    end

    it "contains the loaded stubs" do
      expect(obtain_session.stubs.map(&:stub_id)).to contain_exactly(*loaded_stubs.map(&:stub_id))
    end

    def obtain_session
      subject.find_or_create("some id", logger)
    end

  end

end
