module HttpStub
  module Examples

    class ConfiguratorWithStubControlValues
      include HttpStub::Configurator

      stub_server.add_stub! do |stub|
        stub.match_requests(uri: %r{/stub/regexp/\$key=value}, method: :get)
        stub.respond_with(body: "Regular expression uri stub body")
      end

      stub_server.add_stub! do |stub|
        stub.match_requests(uri: "/stub_with_regular_expression_headers", method: :get, headers: { key: /^match.*/ })
        stub.respond_with(body: "Regular expression headers stub body")
      end

      stub_server.add_stub! do |stub|
        stub.match_requests(
          uri:        "/stub_with_regular_expression_parameters",
          method:     :get,
          parameters: { key: /^match.*/ }
        )
        stub.respond_with(body: "Regular expression parameters stub body")
      end

      stub_server.add_stub! do |stub|
        stub.match_requests(uri: "/stub_with_omitted_headers", method: :get, headers: { key: :omitted })
        stub.respond_with(body: "Omitted headers stub body")
      end

      stub_server.add_stub! do |stub|
        stub.match_requests(uri: "/stub_with_omitted_parameters", method: :get, parameters: { key: :omitted })
        stub.respond_with(body: "Omitted parameters stub body")
      end

      stub_server.add_stub! do |stub|
        stub.match_requests(uri: "/stub_with_response_delay", method: :get)
        stub.respond_with(delay_in_seconds: 1)
      end

    end

  end
end
