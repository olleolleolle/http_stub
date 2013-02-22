module HttpStub
  module Examples

    class ConfigurerWithAlias
      include HttpStub::Configurer

      host "localhost"
      port 8001

      stub_alias "/an_alias", "/path1", method: :get, response: { status: 200, body: "Stub alias body" }
    end

  end
end
