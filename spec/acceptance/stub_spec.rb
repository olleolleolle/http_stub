describe "Stub basics acceptance" do
  include_context "server integration"

  let(:configurator) { HttpStub::Examples::ConfiguratorWithTrivialStubs }

  context "when a stub has no match headers or parameters" do

    context "and it contains a body only" do

      context "and a matching request is made" do

        let(:response) { HTTParty.get("#{server_uri}/stub_with_body_only") }

        it "replays the stubbed body" do
          expect(response.body).to eql("Stub body")
        end

      end

    end

    context "and it contains a response status only" do

      context "and a matching request is made" do

        let(:response) { HTTParty.get("#{server_uri}/stub_with_status_only") }

        it "responds with the stubbed status" do
          expect(response.code).to eql(201)
        end

        it "responds with an empty body" do
          expect(response.body).to eql("")
        end

      end

    end

  end

  context "when a stub has match headers" do

    context "whose values are strings" do

      let(:response) do
        HTTParty.get("#{server_uri}/stub_with_string_match_headers", headers: { "key" => header_value })
      end

      context "and a matching request is made" do

        let(:header_value) { "value" }

        it "replays the stubbed response" do
          expect(response.body).to eql("String match headers body")
        end

      end

      context "and a request with a different header value is made" do

        let(:header_value) { "other_value" }

        it "responds with a 404 status code" do
          expect(response.code).to eql(404)
        end

      end

    end

  end

  context "when a stub has match parameters" do

    context "whose values are strings" do

      let(:response) { HTTParty.get("#{server_uri}/stub_with_string_match_parameters?key=#{parameter_value}") }

      context "and a matching request is made" do

        let(:parameter_value) { "value" }

        it "replays the stubbed response" do
          expect(response.body).to eql("String match parameters body")
        end

      end

      context "and a request with different parameters is made" do

        let(:parameter_value) { "another_value" }

        it "responds with a 404 status code" do
          expect(response.code).to eql(404)
        end

      end

    end

    context "whose values are numerics" do

      let(:response) { HTTParty.get("#{server_uri}/stub_with_numeric_match_parameters?key=#{parameter_value}") }

      context "and a matching request is made" do

        let(:parameter_value) { 88 }

        it "replays the stubbed response" do
          expect(response.body).to eql("Numeric match parameters body")
        end

      end

    end

  end

  describe "when a stub has response headers" do

    context "including a content-type header" do

      context "and a matching request is made" do

        let(:response) { HTTParty.get("#{server_uri}/stub_with_content_type_header") }

        it "responds with the header" do
          expect(response.content_type).to eql("application/xhtml")
        end

      end

    end

    context "that are custom" do

      context "and a matching request is made" do

        let(:expected_response_headers) do
          {
            "some_header"        => "some value",
            "another_header"     => "another value",
            "yet_another_header" => "yet another value"
          }
        end

        let(:response) { HTTParty.get("#{server_uri}/stub_with_response_headers") }

        it "responds with the headers" do
          expected_response_headers.each { |key, value| expect(response.headers[key]).to eql(value) }
        end

      end

    end

  end

  context "when a stub has a response body that is a file" do

    let(:configurator) { HttpStub::Examples::ConfiguratorWithFileResponses }

    context "and a request that matches is made" do

      context "matching a stub with a custom content-type" do

        let(:response) { issue_request }

        it "responds with a status code of 200" do
          expect(response.code).to eql(200)
        end

        it "responds with the configured content type" do
          expect(response.content_type).to eql("application/pdf")
        end

        it "responds with the configured file" do
          expect(response).to contain_file(HttpStub::Examples::ConfiguratorWithFileResponses::FILE_PATH)
        end

        context "and a subsequent request is made that requests the file if it has been modified" do

          let(:first_response)          { issue_request }
          let(:file_last_modified_time) { first_response.headers["Last-Modified"] }

          let(:second_response) { issue_request("if_modified_since" => file_last_modified_time) }

          it "responds with a status code of 304 to indicate the file is unchanged" do
            expect(second_response.code).to eql(304)
          end

          it "responds with no content type" do
            expect(second_response.content_type).to be(nil)
          end

          it "responds with an empty body" do
            expect(second_response.body).to be(nil)
          end

        end

        def issue_request(headers={})
          HTTParty.get("#{server_uri}/stub_response_with_file", headers: headers)
        end

      end

      context "matching a stub with no content-type" do

        let(:response) { HTTParty.get("#{server_uri}/stub_response_with_file_and_no_content_type") }

        it "responds with a default content type of 'application/octet-stream'" do
          expect(response.content_type).to eql("application/octet-stream")
        end

        it "responds with the configured response" do
          expect(response).to contain_file(HttpStub::Examples::ConfiguratorWithFileResponses::FILE_PATH)
        end

      end

    end

  end

end
