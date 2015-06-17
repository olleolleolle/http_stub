describe "Scenario acceptance" do
  include_context "configurer integration"

  context "when a configurer that contains a stub matching a request body schema" do

    let(:configurer)  { HttpStub::Examples::ConfigurerWithSchemaValidatingStub.new }

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

    end

    context "and a request is made that does not contain a request body" do

      let(:response) { issue_request(query: { some_other_key: "some string" }) }

      it "responds with a 404 status code" do
        expect(response.code).to eql(404)
      end

    end

    def issue_request(args)
      HTTParty.post("#{server_uri}/matches_on_body_schema", args)
    end

  end

end
