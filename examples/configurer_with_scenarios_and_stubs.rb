module HttpStub
  module Examples

    class ConfigurerWithScenariosAndStubs
      include HttpStub::Configurer

      stub_server.add_scenario_with_one_stub!("Activated during initialization") do |stub|
        stub.match_requests(uri: "/activated_during_initialization_stub_path", method: :get)
        stub.respond_with(status: 200, body: "Activated during initialization body")
      end
      stub_server.add_scenario_with_one_stub!("Not activated during initialization") do |stub|
        stub.match_requests(uri: "/not_activated_during_initialization_stub_path", method: :get)
        stub.respond_with(status: 200, body: "Not activated during initialization body")
      end
      stub_server.activate!("Activated during initialization")

      stub_server.add_stub! do |stub|
        stub.match_requests(uri: "/stubbed_during_initialization_path", method: :get)
        stub.respond_with(status: 200, body: "Stubbed during initialization body")
      end
    end

  end
end
