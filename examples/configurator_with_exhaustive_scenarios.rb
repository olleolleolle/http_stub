module HttpStub
  module Examples

    class ConfiguratorWithExhaustiveScenarios
      include HttpStub::Configurator

      FILE_PATH = ::File.expand_path("resources/some.pdf", __dir__).freeze

      [ { "key" => "JSON body" }.to_json,
        "<html><body>HTML body</body></html>",
        { file: { path: FILE_PATH, name: File.basename(FILE_PATH) } }].each_with_index do |response_body, i|
        scenario_number = i + 1
        triggered_stubs = (1..3).map do |trigger_number|
          stub_server.build_stub do |stub|
            stub_identifier = "#{scenario_number}_trigger_#{trigger_number}"
            stub.match_requests(
              uri:        "/path_#{scenario_number}_trigger_#{trigger_number}",
              method:     :get,
              headers:    { "request_header_#{stub_identifier}" => "request_header_value_#{stub_identifier}" },
              parameters: { "parameter_#{stub_identifier}" => "parameter_value_#{stub_identifier}" },
              body:       stub.schema(:json,
                                      "type" => "object",
                                      "properties" => {
                                        "property_#{stub_identifier}" =>
                                          { "type" => "property_#{stub_identifier}_type" }
                                      }
                                     )
            )
            stub.respond_with(
              status:           300 + (scenario_number * trigger_number),
              headers:          { "response_header_#{stub_identifier}" => "response_header_value_#{stub_identifier}" },
              body:             "Body of scenario stub #{stub_identifier}",
              delay_in_seconds: 3 * scenario_number * trigger_number
            )
          end
        end

        stub_server.add_scenario_with_one_stub!("Nested scenario #{scenario_number}") do
          match_requests(uri: "/nested_scenario_stub_path_#{scenario_number}")
          respond_with(body: "Body of nested scenario stub #{scenario_number}")
        end

        stub_server.add_scenario!("Scenario #{scenario_number}") do |scenario|
          scenario.add_stub! do |stub|
            stub.match_requests(
              uri:        "/path_#{scenario_number}",
              method:     :get,
              headers:    { "request_header_#{scenario_number}" => "request_header_value_#{scenario_number}" },
              parameters: { "parameter_#{scenario_number}" => "parameter_value_#{scenario_number}" },
              body:       stub.schema(:json,
                                      "type"       => "object",
                                      "properties" => {
                                        "property_#{scenario_number}" =>
                                          { "type" => "property_#{scenario_number}_type" }
                                      }
                                     )
            )
            stub.respond_with(
              status:           200 + scenario_number,
              headers:          { "response_header_#{scenario_number}" => "response_header_value_#{scenario_number}" },
              body:             response_body,
              delay_in_seconds: 8 * scenario_number
            )
            stub.trigger(stubs: triggered_stubs)
          end
          scenario.activate_scenarios!("Nested scenario #{scenario_number}")
        end
      end

    end

  end
end
