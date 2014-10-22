module HttpStub
  module Examples

    class ConfigurerWithComplexInitializer
      include HttpStub::Configurer

      stub_server.add_activator! do |activator|
        activator.on("/activated_during_initialization")
        activator.match_requests("/activated_during_initialization_stub_path", method: :get)
        activator.respond_with(status: 200, body: "Activated during initialization body")
      end
      stub_server.add_activator! do |activator|
        activator.on("/not_activated_during_initialization")
        activator.match_requests("/not_activated_during_initialization_stub_path", method: :get)
        activator.respond_with(status: 200, body: "Not activated during initialization body")
      end
      stub_server.activate!("/activated_during_initialization")

      stub! "/stubbed_during_initialization_path",
            method: :get, response: { status: 200, body: "Stubbed during initialization body" }
    end

  end
end
