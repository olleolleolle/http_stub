module HttpStub
  module Examples

    class ConfigurerWithManyActivators
      include HttpStub::Configurer

      stub_activator "/activator_1", "/path_1", method: :get,
                                                headers: { request_header_1: "request_header_value_1" },
                                                parameters: { parameter_1: "parameter_value_1" },
                                                response: { status: 201,
                                                            headers: { response_header_1: "response_header_value_1" },
                                                            body: "Plain text body",
                                                            delay_in_seconds: 8 * 1 }

      stub_activator "/activator_2", "/path_2", method: :get,
                                                headers: { request_header_2: "request_header_value_2" },
                                                parameters: { parameter_2: "parameter_value_2" },
                                                response: { status: 202,
                                                            headers: { response_header_2: "response_header_value_2" },
                                                            body: { "key" => "JSON body" }.to_json,
                                                            delay_in_seconds: 8 * 2 }

      stub_activator "/activator_3", "/path_3", method: :get,
                                                headers: { request_header_3: "request_header_value_3" },
                                                parameters: { parameter_3: "parameter_value_3" },
                                                response: { status: 203,
                                                            headers: { response_header_3: "response_header_value_3" },
                                                            body: "<html><body>HTML body</body></html>",
                                                            delay_in_seconds: 8 * 3 }
    end

  end
end
