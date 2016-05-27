describe HttpStub::Configurer::DSL::ScenarioActivator do

  class HttpStub::Configurer::DSL::TestableScenarioActivator
    include HttpStub::Configurer::DSL::ScenarioActivator

    def activate_all!(_names)
      # Intentionally blank
    end

  end

  let(:activator) { HttpStub::Configurer::DSL::TestableScenarioActivator.new }

  describe "#activate!" do

    subject { activator.activate!(name) }

    context "when a name is provided" do

      let(:name) { "some name" }

      it "delegates to activate all with the provided name" do
        expect(activator).to receive(:activate_all!).with([ name ])

        subject
      end

    end

    context "when multiple names are provided" do

      let(:names) { (1..3).map { |i| "name #{i}" } }

      context "as multiple arguments" do

        subject { activator.activate!(*names) }

        it "delegates to activate all the provided names" do
          expect(activator).to receive(:activate_all!).with(names)

          subject
        end

      end

      context "as an array" do

        subject { activator.activate!(names) }

        it "delegates to activate all the provided names" do
          expect(activator).to receive(:activate_all!).with(names)

          subject
        end

      end

    end

  end

end
