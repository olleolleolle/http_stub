describe HttpStub::Server::Scenario::Activator do

  let(:logger)                   { instance_double(Logger) }
  let(:stubs)                    { (1..3).map { instance_double(HttpStub::Server::Stub::Stub) } }
  let(:triggered_scenario_names) { [] }
  let(:scenario_triggers)        do
    triggered_scenario_names.map do |scenario_name|
      instance_double(HttpStub::Server::Scenario::Trigger, name: scenario_name)
    end
  end
  let(:scenario)                 do
    instance_double(
      HttpStub::Server::Scenario::Scenario, stubs: stubs, triggered_scenarios: scenario_triggers
    )
  end
  let(:scenario_registry)        { instance_double(HttpStub::Server::Registry).as_null_object }
  let(:stub_registry)            { instance_double(HttpStub::Server::Stub::Registry).as_null_object }
  let(:activator_class)          { HttpStub::Server::Scenario::Activator }

  let(:activator) { activator_class.new(scenario_registry, stub_registry) }

  describe "#activate" do

    subject { activator.activate(scenario, logger) }

    it "adds the scenario's stubs to the stub registry with the provided logger" do
      expect(stub_registry).to receive(:concat).with(stubs, logger)

      subject
    end

    context "when the scenario contains triggered scenarios" do

      let(:triggered_scenario_names) { (1..3).map { |i| "Triggered scenario name #{i}" } }
      let(:triggered_scenarios) do
        triggered_scenario_names.map do
          instance_double(HttpStub::Server::Scenario::Scenario, stubs: [], triggered_scenarios: [])
        end
      end

      before(:each) do
        triggered_scenario_names.zip(triggered_scenarios).each do |triggered_scenario_name, triggered_scenario|
          allow(scenario_registry).to(
            receive(:find).with(triggered_scenario_name, anything).and_return(triggered_scenario)
          )
        end
      end

      it "finds each triggered scenario in the scenario registry" do
        triggered_scenario_names.zip(triggered_scenarios).each do |triggered_scenario_name, triggered_scenario|
          expect(scenario_registry).to(
            receive(:find).with(triggered_scenario_name, logger).and_return(triggered_scenario)
          )
        end

        subject
      end

      context "when the triggered scenario's are found" do

        class HttpStub::Server::Scenario::ActivatorRetainingActivateArgs < HttpStub::Server::Scenario::Activator

          attr_reader :activate_args

          def initialize(scenario_registry, stub_registry)
            super
            @activate_args = []
          end

          def activate(scenario, logger)
            @activate_args << [ scenario, logger ]
            super
          end

        end

        let(:activator_class) { HttpStub::Server::Scenario::ActivatorRetainingActivateArgs }

        it "activates the scenario's" do
          expected_activate_args = triggered_scenarios.reduce([ [ scenario, logger ] ]) do |result, triggered_scenario|
            result << [ triggered_scenario, logger ]
          end

          subject

          expect(activator.activate_args).to eql(expected_activate_args)
        end

      end

      context "when a triggered scenario is not found" do

        let(:scenario_name_not_found) { triggered_scenario_names[1] }

        before(:example) do
          allow(scenario_registry).to(
            receive(:find).with(scenario_name_not_found, anything).and_return(nil)
          )
        end

        it "raises an error indicating the triggered scenario is not found" do
          expect { subject }.to raise_error("Scenario not found with name '#{scenario_name_not_found}'")
        end

      end

    end

  end

end
