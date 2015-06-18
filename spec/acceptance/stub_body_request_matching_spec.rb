describe "Scenario acceptance" do
  include_context "configurer integration"

  context "when a configurer that contains a stub matching a request body schema" do

    let(:configurer) { HttpStub::Examples::ConfigurerWithSchemaValidatingStub.new }

    before(:example) { configurer.class.initialize! }

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
      HTTParty.post("#{server_uri}/matches_on_body_schema", args)
    end

  end

  context "when a configurer that contains a stub with a simple request body" do

    let(:configurer) { HttpStub::Examples::ConfigurerWithSimpleRequestBody.new }

    before(:example) { configurer.class.initialize! }

    context "and a request is made with a string as the request body" do

      context "that matches" do

        let(:response) { issue_request(body: "This is just a simple request body") }

        it "responds with the configured response" do
          expect(response.code).to eql(204)
        end

      end

      context "that does not match" do

        let(:response) { issue_request(body: "This is a request which does not match.") }

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
      HTTParty.post("#{server_uri}/matches_on_simple_request", args)
    end

  end

  context "when a configurer that contains a stub with a regex request body" do

    let(:configurer) { HttpStub::Examples::ConfigurerWithRegexRequestBody.new }

    before(:example) { configurer.class.initialize! }

    context "and a request is made with a string as the request body" do

      context "that matches" do

        let(:response) { issue_request(body: "Some regex content") }

        it "responds with the configured response" do
          expect(response.code).to eql(204)
        end

      end

      context "that does not match" do

        let(:response) { issue_request(body: "Some invalid regex content") }

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
      HTTParty.post("#{server_uri}/matches_on_regex_request", args)
    end

  end

end
