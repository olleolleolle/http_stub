module HttpStub
  module Examples

    class ConfigurerWithRegexRequestBody
      include HttpStub::Configurer

      stub_server.add_scenario_with_one_stub!("match_body_on_regex_request") do
        match_requests(uri: "/matches_on_regex_request", method: :post, body: /Some regex content/)
        respond_with(status: 204)
      end

    end

  end
end
