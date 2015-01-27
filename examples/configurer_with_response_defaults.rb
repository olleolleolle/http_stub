module HttpStub
  module Examples

    class ConfigurerWithResponseDefaults
      include HttpStub::Configurer

      stub_server.response_defaults = { headers: { defaulted_header: "Header value" } }

      stub_server.add_stub! do |stub|
        stub.match_requests("/response_with_defaults", method: :get)
        stub.respond_with(status: 200, body: "Some body")
      end
    end

  end
end
