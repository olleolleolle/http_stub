describe HttpStub::Rake::ServerTasks do

  class HttpStub::Rake::ServerTasksTestCounter

    def self.next
      @counter ||= 0
      @counter += 1
    end

  end

  let(:server_name)  { "server_tasks_test_#{HttpStub::Rake::ServerTasksTestCounter.next}".to_sym }
  let(:default_args) { { port: 8001, name: server_name } }
  let(:args)         { {} }
  let(:configurer)   { double(HttpStub::Configurer).as_null_object }

  before(:example) { HttpStub::Rake::ServerTasks.new(default_args.merge(args)) }

  describe "the configure task" do

    context "when a configurer is provided" do

      let(:args) { { configurer: configurer } }

      context "and the task is executed" do

        it "initializes the provided configurer" do
          expect(configurer).to receive(:initialize!)

          Rake::Task["#{server_name}:configure"].execute
        end

      end

    end

    context "when a configurer is not provided" do

      it "does not generate a task" do
        expect { Rake::Task["#{server_name}:configure"] }.to raise_error(/Don't know how to build task/)
      end

    end

  end

end
