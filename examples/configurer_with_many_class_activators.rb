module HttpStub
  module Examples

    class ConfigurerWithManyActivators
      include HttpStub::Configurer

      [ "Plain text body",
        { "key" => "JSON body" }.to_json,
        "<html><body>HTML body</body></html>" ].each_with_index do |response_body, i|
        activator_number = i + 1
        triggers = (1..3).map do |trigger_number|
          stub_server.build_stub do |stub|
            stub_identifier = "#{activator_number}_trigger_#{trigger_number}"
            stub.match_request(
              "/path_#{activator_number}_trigger_#{trigger_number}",
              method: :get,
              headers: { "request_header_#{stub_identifier}" => "request_header_value_#{stub_identifier}" },
              parameters: { "parameter_#{stub_identifier}" => "parameter_value_#{stub_identifier}" }
            )
            stub.respond_with(
              status: 300 + (activator_number * trigger_number),
              headers: { "response_header_#{stub_identifier}" => "response_header_value_#{stub_identifier}" },
              body: "Body of activator #{stub_identifier}",
              delay_in_seconds: 3 * activator_number * trigger_number
            )
          end
        end

        stub_server.add_activator! do |activator|
          activator.path("/activator_#{activator_number}")
          activator.match_request(
            "/path_#{activator_number}",
            method: :get,
            headers: { "request_header_#{activator_number}" => "request_header_value_#{activator_number}" },
            parameters: { "parameter_#{activator_number}" => "parameter_value_#{activator_number}" }
          )
          activator.respond_with(
            status: 200 + activator_number,
            headers: { "response_header_#{activator_number}" => "response_header_value_#{activator_number}" },
            body: response_body,
            delay_in_seconds: 8 * activator_number
          )
          triggers.each { |trigger| activator.and_add_stub(trigger) }
        end
      end

    end

  end
end
