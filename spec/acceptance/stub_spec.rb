describe "Stub basics acceptance" do
  include_context "configurer integration"

  before(:example) { configurer.initialize! }

  context "when a stub is submitted" do

    context "that contains no request headers or parameters" do

      context "and it contains a response status" do

        before(:example) do
          stub_server.add_stub! do |stub|
            stub.match_requests(uri: "/stub_with_status", method: :get)
            stub.respond_with(status: 201, body: "Stub body")
          end
        end

        context "and a matching request is made" do

          let(:response) { HTTParty.get("#{server_uri}/stub_with_status") }

          it "responds with the stubbed status" do
            expect(response.code).to eql(201)
          end

          it "replays the stubbed body" do
            expect(response.body).to eql("Stub body")
          end

        end

        context "and stubs are cleared" do

          before(:example) { stub_server.clear_stubs! }

          context "and a matching request is made" do

            let(:response) { HTTParty.get("#{server_uri}/stub_with_status") }

            it "responds with a 404 status code" do
              expect(response.code).to eql(404)
            end

          end

        end

      end

      context "and it does not contain a response status" do

        before(:example) do
          stub_server.add_stub! do |stub|
            stub.match_requests(uri: "/stub_without_status", method: :get)
            stub.respond_with(body: "Stub body")
          end
        end

        context "and a matching request is made" do

          let(:response) { HTTParty.get("#{server_uri}/stub_without_status") }

          it "replays the stubbed body" do
            expect(response.body).to eql("Stub body")
          end

        end

      end

      context "and it does not contain a request method" do

        before(:example) do
          stub_server.add_stub! { match_requests(uri: "/stub_without_method").respond_with(body: "Stub body") }
        end

        context "and a request is made with a matching uri" do

          let(:response) { HTTParty.get("#{server_uri}/stub_without_method") }

          it "replays the stubbed body" do
            expect(response.body).to eql("Stub body")
          end

        end

      end

    end

    context "that contains request headers" do

      context "whose values are strings" do

        before(:example) do
          stub_server.add_stub! do
            match_requests(uri: "/stub_with_headers", method: :get, headers: { key: "value" })
            respond_with(status: 202, body: "Another stub body")
          end
        end

        context "and that request is made" do

          let(:response) { HTTParty.get("#{server_uri}/stub_with_headers", headers: { "key" => "value" }) }

          it "replays the stubbed response" do
            expect(response.code).to eql(202)
            expect(response.body).to eql("Another stub body")
          end

        end

        context "and a request with different headers is made" do

          let(:response) { HTTParty.get("#{server_uri}/stub_with_headers", headers: { "key" => "other_value" }) }

          it "responds with a 404 status code" do
            expect(response.code).to eql(404)
          end

        end

      end

    end

    context "that contains request parameters" do

      context "whose values are strings" do

        before(:example) do
          stub_server.add_stub! do
            match_requests(uri: "/stub_with_parameters", method: :get, parameters: { key: "value" })
            respond_with(status: 202, body: "Another stub body")
          end
        end

        context "and that request is made" do

          let(:response) { HTTParty.get("#{server_uri}/stub_with_parameters?key=value") }

          it "replays the stubbed response" do
            expect(response.code).to eql(202)
            expect(response.body).to eql("Another stub body")
          end

        end

        context "and a request with different parameters is made" do

          let(:response) { HTTParty.get("#{server_uri}/stub_with_parameters?key=another_value") }

          it "responds with a 404 status code" do
            expect(response.code).to eql(404)
          end

        end

      end

      context "whose values are numbers" do

        before(:example) do
          stub_server.add_stub! do
            match_requests(uri: "/stub_with_parameters", method: :get, parameters: { key: 88 })
            respond_with(status: 203, body: "Body for parameter number")
          end
        end

        context "and that request is made" do

          let(:response) { HTTParty.get("#{server_uri}/stub_with_parameters?key=88") }

          it "replays the stubbed response" do
            expect(response.code).to eql(203)
            expect(response.body).to eql("Body for parameter number")
          end

        end

      end

    end

    describe "that contains response headers" do

      context "with a content-type header" do

        before(:example) do
          stub_server.add_stub! do
            match_requests(uri: "/some_stub_path", method: :get)
            respond_with(body: "Some stub body", headers: { "content-type" => "application/xhtml" })
          end
        end

        it "registers the stub" do
          response = HTTParty.get("#{server_uri}/some_stub_path")

          expect(response.content_type).to eql("application/xhtml")
        end

      end

      context "which are custom" do

        describe "and an attempt is made to register a response with a other headers" do

          let(:response_headers) do
            {
              "some_header" => "some value",
              "another_header" => "another value",
              "yet_another_header" => "yet another value"
            }
          end

          before(:example) do
            stub_server.add_stub! do |stub|
              stub.match_requests(uri: "/some_stub_path", method: :get)
              stub.respond_with(body: "Some stub body", headers: response_headers)
            end
          end

          it "registers the stub" do
            response = Net::HTTP.get_response("localhost", "/some_stub_path", 8001)

            response_headers.each { |key, value| expect(response[key]).to eql(value) }
          end

        end

      end

    end

    context "that contains a response body that is a file" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithFileResponses }

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
            expect_response_to_contain_file(HttpStub::Examples::ConfigurerWithFileResponses::FILE_PATH)
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
            expect_response_to_contain_file(HttpStub::Examples::ConfigurerWithFileResponses::FILE_PATH)
          end

        end

      end

    end

  end

end
