shared_context "stub payload builder arguments" do

  let(:uri)                       { "/some/uri" }
  let(:stub_method)               { "Some Method" }
  let(:request_headers)           { { request_header_name: "value" } }
  let(:request_parameters)        { { parameter_name: "value" } }
  let(:request_options) do
    {
      method:     stub_method,
      headers:    request_headers,
      parameters: request_parameters
    }
  end
  let(:response_status)           { 500 }
  let(:response_headers)          { { response_header_name: "value" } }
  let(:response_body)             { "Some body" }
  let(:response_delay_in_seconds) { 7 }
  let(:response_options) do
    {
      status:           response_status,
      headers:          response_headers,
      body:             response_body,
      delay_in_seconds: response_delay_in_seconds
    }
  end

end
