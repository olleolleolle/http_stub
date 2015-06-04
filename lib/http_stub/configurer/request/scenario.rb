module HttpStub
  module Configurer
    module Request

      class Scenario

        def initialize(args)
          @name                     = args[:name]
          @stubs                    = args[:stubs]
          @triggered_scenario_names = args[:triggered_scenario_names]
        end

        def payload
          { name: @name, stubs: @stubs.map(&:payload), triggered_scenario_names: @triggered_scenario_names }
        end

        def response_files
          @stubs.map(&:response_files).flatten
        end

        def to_s
          @name
        end

      end

    end
  end
end
