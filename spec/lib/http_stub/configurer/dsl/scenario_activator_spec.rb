describe HttpStub::Configurer::DSL::ScenarioActivator do

  class HttpStub::Configurer::DSL::TestableScenarioActivator
    include HttpStub::Configurer::DSL::ScenarioActivator

    def activate_all!(uris)
      # Intentionally blank
    end

  end

  let(:activator) { HttpStub::Configurer::DSL::TestableScenarioActivator.new }

  describe "#activate!" do

    subject { activator.activate!(uri) }

    context "when a uri is provided" do

      let(:uri) { "some/uri" }

      it "delegates to activate all with the provided uri" do
        expect(activator).to receive(:activate_all!).with([ uri ])

        subject
      end

    end

    context "when multiple uri's are provided" do

      let(:uris) { (1..3).map { |i| "uri/#{i}" } }

      context "as multiple arguments" do

        subject { activator.activate!(*uris) }

        it "delegates to activate all the provided uris" do
          expect(activator).to receive(:activate_all!).with(uris)

          subject
        end

      end

      context "as an array" do

        subject { activator.activate!(uris) }

        it "delegates to activate all the provided uris" do
          expect(activator).to receive(:activate_all!).with(uris)

          subject
        end

      end

    end

  end

end
