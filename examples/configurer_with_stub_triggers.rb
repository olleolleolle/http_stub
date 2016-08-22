module HttpStub
  module Examples

    class ConfigurerWithStubTriggers
      include HttpStub::Configurer

      triggered_scenario_names = (1..3).map do |triggered_scenario_number|
        "Triggered Scenario #{triggered_scenario_number}".tap do |scenario_name|
          stub_server.add_scenario_with_one_stub!(scenario_name) do
            match_requests(uri: "/triggered_scenario_#{triggered_scenario_number}", method: :get)
            respond_with(body: "Triggered scenario body #{triggered_scenario_number}")
          end
        end
      end

      stub_server.add_stub! do |stub|
        stub.match_requests(uri: "/triggers_scenarios", method: :get)
        stub.respond_with(body: "Stub triggering scenarios body")
        stub.trigger(scenarios: triggered_scenario_names)
      end

      triggered_stubs = (1..3).map do |trigger_number|
        stub_server.build_stub do
          match_requests(uri: "/triggered_stub_#{trigger_number}", method: :get)
          respond_with(body: "Triggered stub body #{trigger_number}")
        end
      end

      stub_server.add_stub! do |stub|
        stub.match_requests(uri: "/triggers_stubs", method: :get)
        stub.respond_with(body: "Stub triggerring stubs body")
        stub.trigger(stubs: triggered_stubs)
      end

    end

  end
end
