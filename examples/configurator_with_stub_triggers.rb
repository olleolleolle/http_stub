module HttpStub
  module Examples

    class ConfiguratorWithStubTriggers
      include HttpStub::Configurator

      RESOURCES_DIR = ::File.expand_path("../resources", __FILE__).freeze

      private_constant :RESOURCES_DIR

      TXT_FILE_PATH = "#{RESOURCES_DIR}/example.txt".freeze
      PDF_FILE_PATH = "#{RESOURCES_DIR}/example.pdf".freeze

      triggered_scenario_names = (1..3).map do |scenario_number|
        "Triggered Scenario #{scenario_number}".tap do |scenario_name|
          stub_server.add_scenario_with_one_stub!(scenario_name) do
            match_requests(uri: "/triggered_scenario_#{scenario_number}", method: :get)
            respond_with(status: 200 + scenario_number, body: "Triggered scenario body #{scenario_number}")
          end
        end
      end

      stub_server.add_stub! do |stub|
        stub.match_requests(uri: "/triggers_scenarios", method: :get)
        stub.respond_with(body: "Stub triggering scenarios body")
        stub.trigger(scenarios: triggered_scenario_names)
      end

      triggered_stubs = (1..3).map do |stub_number|
        stub_server.build_stub do
          match_requests(uri: "/triggered_stub_#{stub_number}", method: :get)
          respond_with(status: 200 + stub_number, body: "Triggered stub body #{stub_number}")
        end
      end

      stub_server.add_stub! do |stub|
        stub.match_requests(uri: "/triggers_stubs", method: :get)
        stub.respond_with(body: "Stub triggering stubs body")
        stub.trigger(stubs: triggered_stubs)
      end

      text_trigger = stub_server.build_stub do |stub|
        stub.match_requests(uri: "/triggered_stub_text", method: :get)
        stub.respond_with(body: "Sample trigger stub body")
      end

      txt_file_trigger = stub_server.build_stub do |stub|
        stub.match_requests(uri: "/triggered_stub_txt_file", method: :get)
        stub.respond_with(
          headers: { "content-type" => "text/plain" },
          body:    { file: { path: TXT_FILE_PATH, name: ::File.basename(TXT_FILE_PATH) } }
        )
      end

      pdf_file_trigger = stub_server.build_stub do |stub|
        stub.match_requests(uri: "/triggered_stub_pdf_file", method: :get)
        stub.respond_with(
          headers: { "content-type" => "application/pdf" },
          body:    { file: { path: PDF_FILE_PATH, name: ::File.basename(PDF_FILE_PATH) } }
        )
      end

      stub_server.add_stub! do |stub|
        stub.match_requests(uri: "/stub_with_mixed_response_triggers", method: :get)
        stub.respond_with(body: "Trigger stub body")
        stub.trigger(stubs: [ text_trigger, txt_file_trigger, pdf_file_trigger ])
      end

    end

  end
end
