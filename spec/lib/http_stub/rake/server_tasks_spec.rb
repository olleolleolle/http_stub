describe HttpStub::Rake::ServerTasks do

  describe "the configure task" do

    let(:default_options) { { port: 8001 } }

    before(:each) { HttpStub::Rake::ServerTasks.new(default_options.merge(options)) }

    context "when a configurer is provided" do

      let(:configurer) { double(HttpStub::Configurer) }
      let(:options) { { name: :tasks_configurer_provided_test, configurer: configurer } }

      context "and the task is executed" do

        it "should initialize the provided configurer" do
          configurer.should_receive(:initialize!)

          Rake::Task[:configure_tasks_configurer_provided_test].execute
        end

      end

    end

    context "when a configurer is not provided" do

      let(:options) { { name: :tasks_configurer_not_provided_test } }

      it "should not generate a task" do
        lambda { Rake::Task[:configure_tasks_configurer_not_provided_test] }.should
          raise_error(/Don't know how to build task/)
      end

    end

  end

end
