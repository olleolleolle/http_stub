module HttpStub
  module Examples

    class ConfigurerWithTrivialScenarios
      include HttpStub::Configurer

      (1..3).each do |scenario_number|
        stub_server.add_scenario!("scenario_#{scenario_number}") do |scenario|
          (1..3).each do |i|
            scenario.add_stub! do |stub|
              stub.match_requests("/scenario_stub_path_#{i}", method: :get)
              stub.respond_with(status: 200 + i, body: "Scenario stub #{i} body")
            end
          end
        end
      end

      stub_server.add_scenario!("scenario_activating_another_scenario") do |scenario|
        scenario.add_stub! do |stub|
          stub.match_requests("/scenario_stub_path", method: :get)
          stub.respond_with(status: 200, body: "Scenario stub body")
        end
        scenario.activate!((1..3).map { |i| "scenario_#{i}" })
      end

    end

  end
end
