describe "Scenario acceptance" do
  include_context "configurer integration"

  context "when a configurer that contains a stub matching a request body" do

    let(:configurer) { HttpStub::Examples::ConfigurerWithStubRequestBody.new }

    before(:example) { configurer.class.initialize! }

    context "against an exact match" do

      before(:example) { stub_server.activate!("match_body_exactly_scenario") }

      context "and a request is made with a request body" do

        context "that exactly matches" do

          let(:response) { issue_request(body: "Exactly matches") }

          it "responds with the configured response" do
            expect(response.code).to eql(204)
          end

        end

        context "that does not match" do

          let(:response) { issue_request(body: "Does not match") }

          it "responds with a 404 status code" do
            expect(response.code).to eql(404)
          end

        end

        context "that is empty" do

          let(:response) { issue_request(body: {}) }

          it "responds with a 404 status code" do
            expect(response.code).to eql(404)
          end

        end

      end

      def issue_request(args)
        HTTParty.post("#{server_uri}/match_body_exactly", args)
      end

    end

    context "against a regular expression" do

      before(:example) { stub_server.activate!("match_body_regex_scenario") }

      context "and a request is made with a request body" do

        context "that matches the regular expression" do

          let(:response) { issue_request(body: "matches with additional content") }

          it "responds with the configured response" do
            expect(response.code).to eql(204)
          end

        end

        context "that does not match the regular expression" do

          let(:response) { issue_request(body: "Does not match") }

          it "responds with a 404 status code" do
            expect(response.code).to eql(404)
          end

        end

        context "that is empty" do

          let(:response) { issue_request(body: {}) }

          it "responds with a 404 status code" do
            expect(response.code).to eql(404)
          end

        end

      end

      def issue_request(args)
        HTTParty.post("#{server_uri}/match_body_regex", args)
      end

    end

    context "against a JSON schema" do

      before(:example) { stub_server.activate!("match_body_json_schema_scenario") }

      context "and a request is made with a request body" do

        context "that completely matches" do

          let(:response) do
            issue_request(body: { string_property:  "some string",
                                  integer_property: 88,
                                  float_property:   77.7 }.to_json)
          end

          it "responds with the configured response" do
            expect(response.code).to eql(204)
          end

        end

        context "that partially matches" do

          let(:response) do
            issue_request(body: { string_property: "some string",
                                  integer_property: 88 }.to_json)
          end

          it "responds with a 404 status code" do
            expect(response.code).to eql(404)
          end

        end

        context "that is completely different" do

          let(:response) { issue_request(body: { some_other_key: "some string" }.to_json) }

          it "responds with a 404 status code" do
            expect(response.code).to eql(404)
          end

        end

        context "that is empty" do

          let(:response) { issue_request(body: {}) }

          it "responds with a 404 status code" do
            expect(response.code).to eql(404)
          end

        end

      end

      def issue_request(args)
        HTTParty.post("#{server_uri}/match_body_json_schema", args)
      end

    end

  end

end
