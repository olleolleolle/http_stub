describe "Stub match list acceptance" do
  include_context "configurer integration with stubs recalled"

  describe "GET /http_stub/stubs/matches" do

    let(:response)          { HTTParty.get("#{server_uri}/http_stub/stubs/matches") }
    let(:response_document) { Nokogiri::HTML(response.body) }

    before(:example) { configure_stub_registrator }

    context "when a request has been made matching a stub" do

      before(:example) do
        stub_registrator.register_stub

        stub_registrator.issue_matching_request
      end

      include_context "HTML view including request details"

      it "returns a response body that contains stub response status" do
        expect(response.body).to match(/#{escape_html(stub_registrator.stub_response_status)}/)
      end

      it "returns a response body that contains stub response headers" do
        stub_registrator.stub_response_headers.each do |expected_header_key, expected_header_value|
          expect(response.body).to match(/#{expected_header_key}:#{expected_header_value}/)
        end
      end

      it "returns a response body that contains stub response body" do
        expect(response.body).to match(/#{escape_html(stub_registrator.stub_response_body)}/)
      end

      it "returns a response body that contains a link to the matched stub" do
        stub_link = response_document.css("a.stub").first
        expect(stub_registrator.stub_uri).to end_with(stub_link["href"])
      end

    end

    context "when a request has been made matching a stub whose response includes request references" do

      before(:example) do
        stub_registrator.with_request_parameters
        stub_registrator.with_request_interpolation

        stub_registrator.register_stub

        stub_registrator.issue_matching_request
      end

      it "returns a response body that contains stub response status" do
        expect(response.body).to match(/#{stub_registrator.stub_response_status}/)
      end

      it "returns a response body that contains stub response headers with interpolated request references" do
        expected_stub_response_headers = {
          header_reference:    "request header value 2",
          parameter_reference: "parameter value 2"
        }

        expected_stub_response_headers.each do |expected_header_key, expected_header_value|
          expect(response.body).to match(/#{expected_header_key}:#{expected_header_value}/)
        end
      end

      it "returns a response body that contains stub response body with interpolated request references" do
        expected_stub_response_body = "header: request header value 3, parameter: parameter value 3"

        expect(response.body).to match(/#{escape_html(expected_stub_response_body)}/)
      end

      it "returns a response body that contains a link to the matched stub" do
        stub_link = response_document.css("a.stub").first
        expect(stub_registrator.stub_uri).to end_with(stub_link["href"])
      end

    end

    context "when a request has been made that does not match a stub" do

      before(:example) { stub_registrator.issue_matching_request }

      include_context "HTML view excluding request details"

    end

    context "when a request has been made configuring a stub" do

      before(:example) { stub_registrator.register_stub }

      include_context "HTML view excluding request details"

    end

    context "when a request has been made configuring a scenario" do

      before(:example) { stub_registrator.register_scenario }

      include_context "HTML view excluding request details"

    end

    def configure_stub_registrator
      # intentionally blank
    end

  end

end
