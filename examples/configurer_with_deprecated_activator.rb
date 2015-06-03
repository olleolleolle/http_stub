module HttpStub
  module Examples

    class ConfigurerWithDeprecatedActivator
      include HttpStub::Configurer

      stub_server.add_activator! do |activator|
        activator.on("/an_activator")
        activator.match_requests("/stub_path", method: :get)
        activator.respond_with(status: 200, body: "Stub activator body")
      end
    end

  end
end
