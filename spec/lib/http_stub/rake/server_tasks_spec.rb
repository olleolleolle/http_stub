describe HttpStub::Rake::ServerTasks do

  describe "the configure task" do

    context "when a configurer is provided" do

      let(:configurer) { double(HttpStub::Configurer) }

      before(:each) do
        HttpStub::Rake::ServerTasks.new(name: :tasks_configurer_provided_test, port: 8001, configurer: configurer)
      end

      context "and the task is executed" do

        it "should initialize the provided configurer" do
          configurer.should_receive(:initialize!)

          Rake::Task[:configure_tasks_configurer_provided_test].execute
        end

      end

    end

    context "when a configurer is not provided" do

      before(:each) { HttpStub::Rake::ServerTasks.new(name: :tasks_configurer_not_provided_test, port: 8001) }

      it "should not generate a task" do
        lambda { Rake::Task[:configure_tasks_configurer_not_provided_test] }.should
          raise_error(/Don't know how to build task/)
      end

    end

  end

end
