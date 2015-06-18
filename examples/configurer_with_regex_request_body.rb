module HttpStub
  module Examples

    class ConfigurerWithRegexRequestBody
      include HttpStub::Configurer

      stub_server.add_stub! do |stub|
        stub.match_requests(
          "/matches_on_regex_request", method: :post, body: /Some regex content/
        )
        stub.respond_with(status: 204)
      end

    end

  end
end
