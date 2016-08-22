module HttpStub
  module Configurer
    module Request

      class Triggers

        def initialize(args)
          @scenario_names = args[:scenario_names]
          @stubs          = args[:stubs]
        end

        def response_files
          @stubs.map(&:response_files).flatten
        end

        def payload
          { scenario_names: @scenario_names, stubs: @stubs.map(&:payload) }
        end

      end

    end
  end

end
