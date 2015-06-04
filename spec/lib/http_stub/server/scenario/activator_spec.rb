describe HttpStub::Server::Scenario::Activator do

  let(:request)                 { instance_double(Rack::Request) }
  let(:stubs)                   { (1..3).map { instance_double(HttpStub::Server::Stub::Instance) } }
  let(:triggered_scenario_names) { [] }
  let(:scenario)                do
    instance_double(
      HttpStub::Server::Scenario::Instance, stubs: stubs, triggered_scenario_names: triggered_scenario_names
    )
  end
  let(:scenario_registry)       { instance_double(HttpStub::Server::Registry).as_null_object }
  let(:stub_registry)           { instance_double(HttpStub::Server::Stub::Registry).as_null_object }
  let(:activator_class)         { HttpStub::Server::Scenario::Activator }

  let(:activator) { activator_class.new(scenario_registry, stub_registry) }

  describe "#activate" do

    subject { activator.activate(scenario, request) }

    it "adds the scenario's stubs to the stub registry with the provided request" do
      expect(stub_registry).to receive(:concat).with(stubs, request)

      subject
    end

    context "when the scenario contains triggered scenarios" do

      let(:triggered_scenario_names) { (1..3).map { |i| "triggered_scenario_name/#{i}" } }
      let(:triggered_scenarios) do
        triggered_scenario_names.map do
          instance_double(HttpStub::Server::Scenario::Instance, stubs: [], triggered_scenario_names: [])
        end
      end

      before(:each) do
        triggered_scenario_names.zip(triggered_scenarios).each do |triggered_scenario_name, triggered_scenario|
          allow(scenario_registry).to(
            receive(:find).with(hash_including(criteria: triggered_scenario_name)).and_return(triggered_scenario)
          )
        end
      end

      it "finds each triggered scenario in the scenario registry" do
        triggered_scenario_names.zip(triggered_scenarios).each do |triggered_scenario_name, triggered_scenario|
          expect(scenario_registry).to(
            receive(:find).with(criteria: triggered_scenario_name, request: request).and_return(triggered_scenario)
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

          def activate(scenario, request)
            @activate_args << [ scenario, request ]
            super
          end

        end

        let(:activator_class) { HttpStub::Server::Scenario::ActivatorRetainingActivateArgs }

        it "activates the scenario's" do
          expected_activate_args = triggered_scenarios.reduce([ [ scenario, request ] ]) do |result, triggered_scenario|
            result << [ triggered_scenario, request ]
          end

          subject

          expect(activator.activate_args).to eql(expected_activate_args)
        end

      end

      context "when a triggered scenario is not found" do

        let(:scenario_name_not_found) { triggered_scenario_names[1] }

        before(:example) do
          allow(scenario_registry).to(
            receive(:find).with(hash_including(criteria: scenario_name_not_found)).and_return(nil)
          )
        end

        it "raises an error indicating the triggered scenario is not found" do
          expect { subject }.to raise_error("Scenario not found with name '#{scenario_name_not_found}'")
        end

      end

    end

  end

end
