module HttpStub
  module Examples

    class ConfigurerWithFileResponse
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
    end

  end
end
