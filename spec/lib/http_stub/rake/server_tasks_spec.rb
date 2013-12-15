describe HttpStub::Rake::ServerTasks do

  describe "the configure task" do

    let(:default_args) { { port: 8001 } }

    before(:each) { HttpStub::Rake::ServerTasks.new(default_args.merge(args)) }

    context "when a configurer is provided" do

      let(:configurer) { double(HttpStub::Configurer) }
      let(:args) { { name: :tasks_configurer_provided_test, configurer: configurer } }

      context "and the task is executed" do

        it "should initialize the provided configurer" do
          configurer.should_receive(:initialize!)

          Rake::Task["tasks_configurer_provided_test:configure"].execute
        end

      end

    end

    context "when a configurer is not provided" do

      let(:args) { { name: :tasks_configurer_not_provided_test } }

      it "should not generate a task" do
        lambda { Rake::Task["tasks_configurer_not_provided_test:configure"] }.should
          raise_error(/Don't know how to build task/)
      end

    end

  end

end
