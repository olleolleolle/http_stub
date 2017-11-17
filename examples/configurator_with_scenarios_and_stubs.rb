module HttpStub
  module Examples

    class ConfiguratorWithScenariosAndStubs
      include HttpStub::Configurator

      stub_server.add_scenario_with_one_stub!("Activated initially") do |stub, scenario|
        stub.match_requests(uri: "/scenario_activated_initially_path", method: :get)
        stub.respond_with(status: 200, body: "Activated initially body")
        scenario.activate!
      end
      stub_server.add_scenario_with_one_stub!("Not activated initially") do |stub|
        stub.match_requests(uri: "/scenario_not_activated_initially_path", method: :get)
        stub.respond_with(status: 200, body: "Not activated initially body")
      end

      stub_server.add_stub! do |stub|
        stub.match_requests(uri: "/stub_path", method: :get)
        stub.respond_with(status: 200, body: "Stub body")
      end
    end

  end
end
