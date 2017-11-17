describe HttpStub::Rake::ServerTasks do

  let(:server_name)     { "server_tasks_test_#{SecureRandom.uuid}".to_sym }
  let(:default_args)    { { name: server_name } }
  let(:additional_args) { {} }
  let(:args)            { default_args.merge(additional_args) }

  let(:server_tasks) { HttpStub::Rake::ServerTasks.new(args) }

  context "when a configurator is not provided" do

    it "raises an error on creation indicating a configurator is required" do
      expect { server_tasks }.to raise_error(/configurator must be specified/)
    end

  end

  describe "the start foreground task" do

    let(:configurator)    { HttpStub::ConfiguratorFixture.create }
    let(:additional_args) { { configurator: configurator } }

    let(:task) { Rake::Task["#{server_name}:start:foreground"] }

    before(:example) { server_tasks }

    context "when executed" do

      subject { task.execute }

      it "starts a server with the provided configurator" do
        expect(HttpStub::Server).to receive(:start).with(configurator)

        subject
      end

    end

  end

end
