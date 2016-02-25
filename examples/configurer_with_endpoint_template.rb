module HttpStub
  module Examples

    class ConfigurerWithEndpointTemplate
      include HttpStub::Configurer

      template = stub_server.endpoint_template do |template|
        template.match_requests(uri: "/template_uri")
        template.respond_with(status: 200, body: "template body")
      end

      template.add_stub! { match_requests(uri: "/custom_stub_uri").respond_with(status: 201, body: "custom stub body") }

      template.add_scenario!("Custom request") { match_requests(uri: "/custom_scenario_uri") }

      template.add_scenario!("Custom response", status: 202, body: "custom scenario body")

    end

  end
end
