module HttpStub
  module Examples

    class ConfigurerWithSimpleRequestBody
      include HttpStub::Configurer

      stub_server.add_stub! do |stub|
        stub.match_requests(
          "/matches_on_body_schema", method: :post, body: "This is just a simple request body"
        )
        stub.respond_with(status: 204)
      end

    end

  end
end
