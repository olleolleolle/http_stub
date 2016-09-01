module HttpStub
  module Examples

    class ConfigurerWithSessions
      include HttpStub::Configurer

      stub_server.session_identifier = { header: :session_id }

      stub_server.add_scenario_with_one_stub!("Some Scenario") do
        match_requests(uri: "/matching_path", method: :get)
        respond_with(body: "Some matched payload")
      end

    end

  end
end
