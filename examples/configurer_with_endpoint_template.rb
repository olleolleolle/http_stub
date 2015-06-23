module HttpStub
  module Examples

    class ConfigurerWithEndpointTemplate
      include HttpStub::Configurer

      template = stub_server.endpoint_template do |template|
        template.match_requests("/template_uri")
        template.respond_with(status: 200, body: "template body")
      end

      template.add_scenario!("custom_request") { match_requests("/custom_uri") }

      template.add_scenario!("custom_response", status: 202, body: "custom body")

    end

  end
end
