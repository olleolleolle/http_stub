module HttpStub
  module Server
    module Session

      class Session

        attr_reader :id

        def initialize(id, scenario_registry, memory_session)
          @id                  = id
          @scenario_registry   = scenario_registry
          @stub_registry       = HttpStub::Server::Stub::Registry.new(memory_session)
          @stub_match_registry = HttpStub::Server::Registry.new("stub match")
          @stub_miss_registry  = HttpStub::Server::Registry.new("stub miss")
        end

        def matches?(id, _logger)
          id == @id
        end

        def activate_scenario!(name, logger)
          found_scenario = @scenario_registry.find(name, logger)
          raise HttpStub::Server::Scenario::NotFoundError, name unless found_scenario
          @stub_registry.concat(found_scenario.stubs, logger)
          found_scenario.triggered_scenarios.each { |scenario| activate_scenario!(scenario.name, logger) }
        end

        def add_stub(stub, logger)
          @stub_registry.add(stub, logger)
        end

        def find_stub(id, logger)
          @stub_registry.find(id, logger)
        end

        def stubs
          @stub_registry.all
        end

        def match(request, logger)
          @stub_registry.match(request, logger)
        end

        def add_match(match, logger)
          @stub_match_registry.add(match, logger)
          match.stub.triggers.scenario_names.each { |scenario_name| activate_scenario!(scenario_name, logger) }
          match.stub.triggers.stubs.each { |stub| add_stub(stub, logger) }
        end

        def matches
          @stub_match_registry.all
        end

        def last_match(args, logger)
          @stub_match_registry.find(args, logger)
        end

        def add_miss(miss, logger)
          @stub_miss_registry.add(miss, logger)
        end

        def misses
          @stub_miss_registry.all
        end

        def reset(logger)
          @stub_miss_registry.clear(logger)
          @stub_match_registry.clear(logger)
          @stub_registry.reset(logger)
        end

        def clear(logger)
          [ @stub_miss_registry, @stub_match_registry, @stub_registry ].each { |registry| registry.clear(logger) }
        end

      end

    end
  end
end
