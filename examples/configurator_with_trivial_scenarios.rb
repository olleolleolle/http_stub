module HttpStub
  module Examples

    class ConfiguratorWithTrivialScenarios
      include HttpStub::Configurator

      (1..3).each do |scenario_number|
        stub_server.add_scenario!("Scenario #{scenario_number}") do |scenario|
          (1..3).each do |i|
            scenario.add_stub! do |stub|
              stub.match_requests(uri: "/scenario_stub_path_#{i}", method: :get)
              stub.respond_with(status: 200 + i, body: "Scenario stub #{i} body")
            end
          end
        end
      end

      stub_server.add_scenario_with_one_stub!("Activates another scenario") do |stub, scenario|
        stub.match_requests(uri: "/scenario_stub_path", method: :get)
        stub.respond_with(status: 200, body: "Scenario stub body")
        scenario.activate_scenarios!((1..3).map { |i| "Scenario #{i}" })
      end

    end

  end
end
