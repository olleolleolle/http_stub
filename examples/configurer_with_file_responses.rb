module HttpStub
  module Examples

    class ConfigurerWithFileResponses
      include HttpStub::Configurer

      FILE_PATH = ::File.expand_path("../resources/some.pdf", __FILE__).freeze

      stub_server.add_stub! do |stub|
        stub.match_requests("/stub_response_with_file", method: :get)
        stub.respond_with(
          status: 200,
          headers: { "content-type" => "application/pdf" },
          body: { file: { path: FILE_PATH, name: File.basename(FILE_PATH) } }
        )
      end

      stub_server.add_stub! do |stub|
        stub.match_requests("/stub_response_with_file_and_no_content_type", method: :get)
        stub.respond_with(body: { file: { path: FILE_PATH, name: File.basename(FILE_PATH) } })
      end

      stub_server.add_scenario!("scenario_with_file") do |scenario|
        scenario.add_stub! do |stub|
          stub.match_requests("/activated_response_with_file", method: :get)
          stub.respond_with(
            status: 200,
            headers: { "content-type" => "application/pdf" },
            body: { file: { path: FILE_PATH, name: File.basename(FILE_PATH) } }
          )
        end
      end

    end

  end
end
