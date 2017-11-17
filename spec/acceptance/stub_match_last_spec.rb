describe "Stub matches last acceptance" do
  include_context "server integration"

  describe "GET /http_stub/stubs/matches/last" do
    include_context "configurator with stub builder and requester"

    let(:request_prior_to_last_match_request) { stub_requester.issue_matching_request}
    let(:ensure_stub_request_is_issued)       { request_prior_to_last_match_request }

    let(:request_parameters) { { uri: stub_match_rules[:uri], method: stub_match_rules[:method] } }
    let(:last_match_request) { HTTParty.get("#{server_uri}/http_stub/stubs/matches/last", query: request_parameters) }
    let(:response)           do
      request_prior_to_last_match_request
      last_match_request
    end
    let(:json_response)      { JSON.parse(response.body) }

    context "when a request has been made matching a stub against request headers" do

      it "returns a 200 response" do
        expect(response.code).to eql(200)
      end

      it "returns JSON containing the matching requests uri" do
        expect_match_request_to_include("uri" => stub_match_rules[:uri])
      end

      it "returns JSON containing the matching requests method" do
        expect_match_request_to_include("method" => stub_match_rules[:method])
      end

      it "returns JSON containing the matching requests headers whose names are in uppercase" do
        stub_match_rules[:headers].each do |header_key, expected_header_value|
          expect_match_request_to_include("headers" => hash_including(header_key.upcase => expected_header_value))
        end
      end

      it "returns JSON containing the matches response status" do
        expect_match_response_to_include("status" => expected_match_response[:status])
      end

      it "returns JSON containing the matches response headers" do
        expected_match_response[:headers].each do |expected_header_key, expected_header_value|
          expect_match_response_to_include("headers" => hash_including(expected_header_key => expected_header_value))
        end
      end

      it "returns JSON containing the matches response body" do
        expect_match_response_to_include("body" => expected_match_response[:body])
      end

      it "returns JSON containing the uri of the matched stub" do
        expect_match_stub_to_include("uri" => stub_builder.stub_uri)
      end

      it "returns JSON containing the request match rules of the matched stub" do
        expect_match_stub_to_include("match_rules" => hash_including("uri" => stub_match_rules[:uri]))
      end

      it "returns JSON containing the configured response of the matched stub" do
        expect_match_stub_to_include("response" => hash_including("status" => stub_response[:status]))
      end

    end

    context "when a request has been made matching a stub against request parameters" do

      before(:example) { stub_builder.with_request_parameters! }

      it "returns JSON containing the requests parameters" do
        ensure_stub_request_is_issued

        stub_request[:parameters].each do |expected_parameter_key, expected_parameter_value|
          expect_match_request_to_include(
            "parameters" => hash_including(expected_parameter_key => expected_parameter_value)
          )
        end
      end

    end
    
    context "when a request has been made matching a stub against a body" do

      it "returns JSON containing the requests body" do
        ensure_stub_request_is_issued

        expect_match_request_to_include("body" => stub_request[:body])
      end

    end

    context "when a request has been made matching a stub whose response includes request interpolation" do

      before(:example) { stub_builder.with_request_parameters!.and.with_request_interpolation! }

      it "returns a 200 response" do
        expect(response.code).to eql(200)
      end

      it "returns JSON containing the response block source code of the matched stub" do
        expect_match_stub_to_include("response" => hash_including("blocks" => [ stub_response[:block].source ]))
      end

      it "returns JSON containing the matches response headers with interpolated request values" do
        expected_stub_response_headers = {
          "header_reference"    => "request header value 2",
          "parameter_reference" => "parameter value 2"
        }

        expected_stub_response_headers.each do |expected_header_key, expected_header_value|
          expect_match_response_to_include("headers" => hash_including(expected_header_key => expected_header_value))
        end
      end

      it "returns JSON containing the matches response body with interpolated request values" do
        expected_stub_response_body = "header: request header value 3, parameter: parameter value 3"

        expect_match_response_to_include("body" => expected_stub_response_body)
      end

    end

    context "when a request has been made that does not match a stub" do

      let(:request_prior_to_last_match_request) { stub_requester.issue_non_matching_request }

      it "returns a 404 response" do
        expect(response.code).to eql(404)
      end

    end

    context "when no request has been made" do

      let(:request_prior_to_last_match_request) { nil }

      it "returns a 404 response" do
        expect(response.code).to eql(404)
      end

    end

    def expect_match_request_to_include(hash)
      expect(json_response).to(include("request" => hash_including(hash)))
    end

    def expect_match_response_to_include(hash)
      expect(json_response).to(include("response" => hash_including(hash)))
    end

    def expect_match_stub_to_include(hash)
      response_hash = json_response
      expect(response_hash).to(include("stub" => hash_including(hash)))
    end

  end

end
