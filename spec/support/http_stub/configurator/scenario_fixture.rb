module HttpStub
  module Configurator

    class ScenarioFixture

      class << self

        def create_hash(args={})
          hash = { activated: false, stubs: [], triggered_scenario_names: [] }.merge(args)
          hash[:name] ||= next_name
          hash
        end

        def create(args={})
          hash = self.create_hash(args)
          HttpStub::Configurator::Scenario.new(hash[:name], nil).tap do |scenario|
            scenario.add_stubs!(hash[:stubs])
            scenario.activate_scenarios!(hash[:triggered_scenario_names])
            scenario.activate! if hash[:activated]
          end
        end

        def many
          (1..3).map { self.create }
        end

        private

        def next_name
          @next_id ||= 0
          "scenario #{@next_id += 1}"
        end

      end

    end

  end
end
