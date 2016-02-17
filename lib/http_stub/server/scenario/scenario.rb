module HttpStub
  module Server
    module Scenario

      class Scenario

        attr_reader :name, :stubs, :triggered_scenario_names

        def initialize(args)
          @args                     = args
          @name                     = @args["name"]
          @stubs                    = args["stubs"].map { |stub_args| HttpStub::Server::Stub.create(stub_args) }
          @triggered_scenario_names = @args["triggered_scenario_names"]
        end

        def matches?(name, _logger)
          @name == name
        end

        def uri
          "/#{@name}"
        end

        def detail_uri
          "/http_stub/scenario" + uri
        end

        def triggered_scenarios
          @triggered_scenario_names.reduce([]) { |result, name| result << [ name, "/#{name}" ] }
        end

        def to_s
          @args.to_s
        end

      end

    end
  end
end
