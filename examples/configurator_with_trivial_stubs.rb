module HttpStub
  module Examples

    class ConfiguratorWithTrivialStubs
      include HttpStub::Configurator

      stub_server.add_stub! do
        match_requests(uri: "/stub_with_body_only", method: :get).respond_with(body: "Stub body")
      end

      stub_server.add_stub! do |stub|
        stub.match_requests(uri: "/stub_with_status_only", method: :get)
        stub.respond_with(status: 201)
      end

      stub_server.add_stub! do
        match_requests(uri: "/stub_with_string_match_headers", method: :get, headers: { key: "value" })
        respond_with(body: "String match headers body")
      end

      stub_server.add_stub! do
        match_requests(uri: "/stub_with_string_match_parameters", method: :get, parameters: { key: "value" })
        respond_with(body: "String match parameters body")
      end

      stub_server.add_stub! do
        match_requests(uri: "/stub_with_numeric_match_parameters", method: :get, parameters: { key: 88 })
        respond_with(body: "Numeric match parameters body")
      end

      stub_server.add_stub! do
        match_requests(uri: "/stub_with_content_type_header", method: :get)
        respond_with(headers: { "content-type" => "application/xhtml" })
      end

      stub_server.add_stub! do |stub|
        stub.match_requests(uri: "/stub_with_response_headers", method: :get)
        stub.respond_with(
          headers: {
            some_header:        "some value",
            another_header:     "another value",
            yet_another_header: "yet another value"
          }
        )
      end

    end

  end
end
