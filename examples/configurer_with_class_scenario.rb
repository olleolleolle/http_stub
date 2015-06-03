module HttpStub
  module Examples

    class ConfigurerWithClassScenario
      include HttpStub::Configurer

      stub_server.add_scenario!("/a_scenario") do |scenario|
        (1..3).each do |i|
          scenario.add_stub! do |stub|
            stub.match_requests("/scenario_stub_path_#{i}", method: :get)
            stub.respond_with(status: 200 + i, body: "Scenario stub #{i} body")
          end
        end
      end
    end

  end
end
