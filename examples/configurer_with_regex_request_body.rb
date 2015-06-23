module HttpStub
  module Examples

    class ConfigurerWithRegexRequestBody
      include HttpStub::Configurer

      stub_server.add_one_stub_scenario!("match_body_on_regex_request") do
        match_requests("/matches_on_regex_request", method: :post, body: /Some regex content/)
        respond_with(status: 204)
      end

    end

  end
end
