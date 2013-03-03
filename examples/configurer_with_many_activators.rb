module HttpStub
  module Examples

    class ConfigurerWithManyActivators
      include HttpStub::Configurer

      host "localhost"
      port 8001

      stub_activator "/activator1", "/path1", method: :get, parameters: { param1: "value1" },
                                              response: { status: 201, body: "Plain text body" }
      stub_activator "/activator2", "/path2", method: :get, parameters: { param2: "value2" },
                                              response: { status: 202, body: { "key" => "JSON body" }.to_json }
      stub_activator "/activator3", "/path3", method: :get, parameters: { param3: "value3" },
                                              response: { status: 203, body: "<html><body>HTML body</body></html>" }
    end

  end
end
