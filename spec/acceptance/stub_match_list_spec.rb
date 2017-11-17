describe "Stub match list acceptance" do
  include_context "server integration"

  describe "GET /http_stub/stubs/matches" do
    include_context "configurator with stub builder and requester"

    let(:response)          do
      request_prior_to_match_list_request
      HTTParty.get("#{server_uri}/http_stub/stubs/matches")
    end
    let(:response_document) { Nokogiri::HTML(response.body) }

    context "when a request has been made matching a stub" do

      let(:request_prior_to_match_list_request) { stub_requester.issue_matching_request }

      include_context "HTML view including a stub request"

      it "returns a response body that contains stub response status" do
        expect(response.body).to match(/#{escape_html(stub_response[:status])}/)
      end

      it "returns a response body that contains stub response headers" do
        stub_response[:headers].each do |expected_header_key, expected_header_value|
          expect(response.body).to match(/#{expected_header_key}:#{expected_header_value}/)
        end
      end

      it "returns a response body that contains stub response body" do
        expect(response.body).to match(/#{escape_html(stub_response[:body])}/)
      end

      it "returns a response body that contains a link to the matched stub" do
        stub_link = response_document.css("a.stub").first
        expect(stub_builder.stub_uri).to end_with(stub_link["href"])
      end

      context "whose response includes request interpolation" do

        before(:example) { stub_builder.with_request_parameters!.and.with_request_interpolation! }

        it "returns a response body that contains the matches response status" do
          expect(response.body).to match(/#{expected_match_response[:status]}/)
        end

        it "returns a response body that contains the matches response headers with interpolated request references" do
          expected_match_response[:headers].each do |expected_header_key, expected_header_value|
            expect(response.body).to match(/#{expected_header_key}:#{expected_header_value}/)
          end
        end

        it "returns a response body that contains the matches response body with interpolated request references" do
          expect(response.body).to match(/#{escape_html(expected_match_response[:body])}/)
        end

        it "returns a response body that contains a link to the matched stub" do
          stub_link = response_document.css("a.stub").first
          expect(stub_builder.stub_uri).to end_with(stub_link["href"])
        end

      end

    end

    context "when a request has been made that does not match a stub" do

      let(:request_prior_to_match_list_request) { stub_requester.issue_non_matching_request }

      include_context "HTML view excluding a stub request"

    end

  end

end
