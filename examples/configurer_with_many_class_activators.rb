module HttpStub
  module Examples

    class ConfigurerWithManyActivators
      include HttpStub::Configurer

      stub_activator "/activator1", "/path1", method: :get,
                                              headers: { header1: "header_value1" },
                                              parameters: { param1: "param_value1" },
                                              response: { status: 201, body: "Plain text body" }
      stub_activator "/activator2", "/path2", method: :get,
                                              headers: { header2: "header_value2" },
                                              parameters: { param2: "param_value2" },
                                              response: { status: 202, body: { "key" => "JSON body" }.to_json }
      stub_activator "/activator3", "/path3", method: :get,
                                              headers: { header3: "header_value3" },
                                              parameters: { param3: "param_value3" },
                                              response: { status: 203, body: "<html><body>HTML body</body></html>" }
    end

  end
end
