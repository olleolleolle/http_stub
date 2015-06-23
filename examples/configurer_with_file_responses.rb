module HttpStub
  module Examples

    class ConfigurerWithFileResponses
      include HttpStub::Configurer

      FILE_PATH = ::File.expand_path("../resources/some.pdf", __FILE__).freeze

      stub_server.add_stub! do
        match_requests("/stub_response_with_file", method: :get)
        respond_with(
          status: 200,
          headers: { "content-type" => "application/pdf" },
          body: { file: { path: FILE_PATH, name: File.basename(FILE_PATH) } }
        )
      end

      stub_server.add_stub! do
        match_requests("/stub_response_with_file_and_no_content_type", method: :get)
        respond_with(body: { file: { path: FILE_PATH, name: File.basename(FILE_PATH) } })
      end

      stub_server.add_one_stub_scenario!("scenario_with_file") do
        match_requests("/activated_response_with_file", method: :get)
        respond_with(
          status: 200,
          headers: { "content-type" => "application/pdf" },
          body: { file: { path: FILE_PATH, name: File.basename(FILE_PATH) } }
        )
      end

    end

  end
end
