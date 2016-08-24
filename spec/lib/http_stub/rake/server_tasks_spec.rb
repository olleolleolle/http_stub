describe HttpStub::Rake::ServerTasks do

  class HttpStub::Rake::ServerTasksTestCounter

    def self.next
      @counter ||= 0
      @counter += 1
    end

  end

  let(:server_name)     { "server_tasks_test_#{HttpStub::Rake::ServerTasksTestCounter.next}".to_sym }
  let(:default_args)    { { port: 8001, name: server_name } }
  let(:additional_args) { {} }
  let(:args)            { default_args.merge(additional_args) }
  let(:configurer)      { double(HttpStub::Configurer).as_null_object }

  before(:example) { HttpStub::Rake::ServerTasks.new(args) }

  describe "the configure task" do

    let(:task) { Rake::Task["#{server_name}:configure"] }

    context "when executed" do

      subject { task.execute }

      context "with a configurer" do

        let(:additional_args) { { configurer: configurer } }

        it "initializes the provided configurer" do
          expect(configurer).to receive(:initialize!)

          subject
        end

      end

    end

    context "when a configurer is not provided" do

      it "does not generate a task" do
        expect { task }.to raise_error(/Don't know how to build task/)
      end

    end

  end

  describe "the start foreground task" do

    let(:application) { HttpStub::Server::Application::Application }

    let(:task) { Rake::Task["#{server_name}:start:foreground"] }

    context "when executed" do

      subject { task.execute }

      before(:example) do
        allow(HttpStub::Server::Application::Application).to receive(:configure)
        allow(HttpStub::Server::Application::Application).to receive(:run!)
      end

      it "configures the application using the tasks arguments" do
        expect(application).to receive(:configure).with(args)

        subject
      end

      it "runs the configured application" do
        expect(application).to receive(:configure).ordered
        expect(application).to receive(:run!).ordered

        subject
      end

    end

  end

end
