module HttpStub
  module Examples

    class ConfiguratorWithEndpointTemplate
      include HttpStub::Configurator

      template = stub_server.endpoint_template do
        match_requests(uri: "/template_uri").respond_with(status: 200, body: "template body")
      end

      template.add_stub! { match_requests(uri: "/custom_stub_uri").respond_with(status: 201, body: "custom stub body") }

      template.add_scenario!("Custom request") { match_requests(uri: "/custom_scenario_uri") }

      template.add_scenario!("Custom response", status: 202, body: "custom scenario body")

      template.add_scenario!("Initially activated via method chaining") do
        match_requests(uri: "/scenario_activated_via_chaining").respond_with(body: "scenario activated via chaining")
      end.activate!

      template.add_scenario!("Initially activated via a block") do |stub, scenario|
        stub.match_requests(uri: "/scenario_activated_via_a_block")
        stub.respond_with(body: "scenario activated via a block")
        scenario.activate!
      end

    end

  end
end
