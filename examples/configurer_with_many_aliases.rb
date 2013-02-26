module HttpStub
  module Examples

    class ConfigurerWithManyAliases
      include HttpStub::Configurer

      host "localhost"
      port 8001

      stub_alias "/alias1", "/path1", method: :get, response: { status: 201, body: "Plain text body" }
      stub_alias "/alias2", "/path2", method: :get, response: { status: 202, body: { "key" => "JSON body" }.to_json }
      stub_alias "/alias3", "/path3", method: :get, response: { status: 203, body: "<html><body>HTML body</body></html>" }
    end

  end
end
