describe "Stub matches last acceptance" do
  include_context "configurer integration"

  before(:example) { configurer.initialize! }

  after(:example) { configurer.clear_stubs! }

  describe "GET /http_stub/stubs/matches/last" do

    let(:request_uri)        { stub_registrator.request_uri }
    let(:request_method)     { stub_registrator.request_method }
    let(:request_parameters) { { uri: request_uri, method: request_method } }
    let(:response)           { HTTParty.get("#{server_uri}/http_stub/stubs/matches/last", query: request_parameters) }
    let(:json_response)      { JSON.parse(response.body) }

    before(:example) { configure_stub_registrator }

    context "when a request has been made matching a stub" do

      before(:example) do
        stub_registrator.register_stub

        stub_registrator.issue_matching_request
      end

      it "returns a 200 response" do
        expect(response.code).to eql(200)
      end

      it "returns JSON containing the requests uri" do
        expect_match_request_to_include("uri" => request_uri)
      end

      it "returns JSON containing the requests method" do
        expect_match_request_to_include("method" => request_method)
      end

      it "returns JSON containing the requests headers whose names are in uppercase" do
        stub_registrator.request_headers.each do |header_key, expected_header_value|
          expect_match_request_to_include("headers" => hash_including(header_key.upcase => expected_header_value))
        end
      end

      context "when the request contains parameters" do

        def configure_stub_registrator
          stub_registrator.with_request_parameters
        end

        it "returns JSON containing the requests parameters" do
          stub_registrator.request_parameters.each do |expected_parameter_key, expected_parameter_value|
            expect_match_request_to_include(
              "parameters" => hash_including(expected_parameter_key => expected_parameter_value)
            )
          end
        end

      end

      context "when the request contains a body" do

        def configure_stub_registrator
          stub_registrator.with_request_body
        end

        it "returns JSON containing the requests body" do
          expect_match_request_to_include("body" => stub_registrator.request_body)
        end

      end

      it "returns JSON containing the matches response status" do
        expect_match_response_to_include("status" => stub_registrator.stub_response_status)
      end

      it "returns JSON containing the matches response headers" do
        stub_registrator.stub_response_headers.each do |expected_header_key, expected_header_value|
          expect_match_response_to_include("headers" => hash_including(expected_header_key => expected_header_value))
        end
      end

      it "returns JSON containing the matches response body" do
        expect_match_response_to_include("body" => stub_registrator.stub_response_body)
      end

      it "returns JSON containing the uri of the matched stub" do
        expect(json_response).to include("stub" => hash_including("uri" => stub_registrator.stub_uri))
      end

    end

    context "when a request has been made matching a stub whose response includes request references" do

      before(:example) do
        stub_registrator.with_request_parameters
        stub_registrator.with_request_interpolation

        stub_registrator.register_stub

        stub_registrator.issue_matching_request
      end

      it "returns a 200 response" do
        expect(response.code).to eql(200)
      end

      it "returns JSON containing the matches response headers with interpolated request references" do
        expected_stub_response_headers = {
          "header_reference"    => "request header value 2",
          "parameter_reference" => "parameter value 2"
        }

        expected_stub_response_headers.each do |expected_header_key, expected_header_value|
          expect_match_response_to_include("headers" => hash_including(expected_header_key => expected_header_value))
        end
      end

      it "returns JSON containing the matches response body with interpolated request references" do
        expected_stub_response_body = "header: request header value 3, parameter: parameter value 3"

        expect_match_response_to_include("body" => expected_stub_response_body)
      end

    end

    context "when a request has been made that does not match a stub" do

      before(:example) { stub_registrator.issue_matching_request }

      it "returns a 404 response" do
        expect(response.code).to eql(404)
      end

    end

    context "when a request has been made configuring a stub" do

      before(:example) { stub_registrator.register_stub }

      it "returns a 404 response" do
        expect(response.code).to eql(404)
      end

    end

    context "when a request has been made configuring a scenario" do

      before(:example) { stub_registrator.register_scenario }

      it "returns a 404 response" do
        expect(response.code).to eql(404)
      end

    end

    def configure_stub_registrator
      # intentionally blank
    end

    def expect_match_request_to_include(hash)
      expect(json_response).to(include("request" => hash_including(hash)))
    end

    def expect_match_response_to_include(hash)
      expect(json_response).to(include("response" => hash_including(hash)))
    end

  end

end
