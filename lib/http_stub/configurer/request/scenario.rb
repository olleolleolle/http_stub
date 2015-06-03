module HttpStub
  module Configurer
    module Request

      class Scenario

        def initialize(args)
          @activation_uri = args[:activation_uri]
          @stubs          = args[:stubs]
        end

        def payload
          { activation_uri: @activation_uri, stubs: @stubs.map(&:payload) }
        end

        def response_files
          @stubs.map(&:response_files).flatten
        end

        def to_s
          @activation_uri
        end

      end

    end
  end
end
