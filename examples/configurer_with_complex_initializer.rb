module HttpStub
  module Examples

    class ConfigurerWithComplexInitializer
      include HttpStub::Configurer

      stub_activator "/activated_during_initialization", "/activated_during_initialization_stub_path",
                     method: :get, response: { status: 200, body: "Activated during initialization body" }
      stub_activator "/not_activated_during_initialization", "/not_activated_during_initialization_stub_path",
                     method: :get, response: { status: 200, body: "Not activated during initialization body" }

      activate! "/activated_during_initialization"

      stub! "/stubbed_during_initialization_path",
            method: :get, response: { status: 200, body: "Stubbed during initialization body" }
    end

  end
end
