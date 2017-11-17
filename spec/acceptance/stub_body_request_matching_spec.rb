describe "Scenario acceptance" do

  context "when a server is started that is configured with a stub matching a request body" do
    include_context "server integration"

    let(:configurator) { HttpStub::Examples::ConfiguratorWithStubRequestBody }

    context "against an exact match" do

      before(:example) { client.activate!("Match body exactly") }

      context "and a request is made with a request body" do

        context "that exactly matches" do

          let(:response) { issue_request(body: "Exactly matches") }

          it "responds with the composed response" do
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

      before(:example) { client.activate!("Match body regex") }

      context "and a request is made with a request body" do

        context "that matches the regular expression" do

          let(:response) { issue_request(body: "matches with additional content") }

          it "responds with the composed response" do
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

      before(:example) { client.activate!("Match body JSON schema") }

      context "and a request is made with a request body" do

        context "that completely matches" do

          let(:response) do
            issue_request(body: { string_property:  "some string",
                                  integer_property: 88,
                                  float_property:   77.7 }.to_json)
          end

          it "responds with the composed response" do
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
