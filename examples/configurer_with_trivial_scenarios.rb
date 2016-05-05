module HttpStub
  module Examples

    class ConfigurerWithTrivialScenarios
      include HttpStub::Configurer

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

      stub_server.add_scenario!("Activates another scenario") do |scenario|
        scenario.add_stub! do |stub|
          stub.match_requests(uri: "/scenario_stub_path", method: :get)
          stub.respond_with(status: 200, body: "Scenario stub body")
        end
        scenario.activate!((1..3).map { |i| "Scenario #{i}" })
      end

    end

  end
end
