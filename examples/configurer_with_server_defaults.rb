module HttpStub
  module Examples

    class ConfigurerWithServerDefaults
      include HttpStub::Configurer

      stub_server.request_defaults  = { headers: { defaulted_request_header: "Request header value" } }
      stub_server.response_defaults = { status: 203, headers: { defaulted_response_header: "Response header value" } }

      stub_server.add_stub! do
        match_requests(uri: "/has_defaults", method: :get)
        respond_with(body: "Some body")
      end

      stub_server.add_stub! do
        match_requests(uri: "/also_has_defaults", method: :get)
        respond_with(body: "Also some body")
      end

    end

  end
end
