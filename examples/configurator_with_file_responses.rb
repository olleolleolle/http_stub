module HttpStub
  module Examples

    class ConfiguratorWithFileResponses
      include HttpStub::Configurator

      FILE_PATH = ::File.expand_path("resources/example.pdf", __dir__).freeze

      stub_server.add_stub! do
        match_requests(uri: "/stub_response_with_file", method: :get)
        respond_with(
          headers: { "content-type" => "application/pdf" },
          body:    { file: { path: FILE_PATH, name: ::File.basename(FILE_PATH) } }
        )
      end

      stub_server.add_stub! do
        match_requests(uri: "/stub_response_with_file_and_no_content_type", method: :get)
        respond_with(body: { file: { path: FILE_PATH, name: ::File.basename(FILE_PATH) } })
      end

      stub_server.add_scenario_with_one_stub!("Scenario with file") do
        match_requests(uri: "/activated_response_with_file", method: :get)
        respond_with(
          headers: { "content-type" => "application/pdf" },
          body:    { file: { path: FILE_PATH, name: ::File.basename(FILE_PATH) } }
        )
      end

    end

  end
end
