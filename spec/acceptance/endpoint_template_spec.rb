describe "Endpoint Template acceptance" do
  include_context "configurer integration"

  context "when a configurer contains an endpoint template" do

    let(:configurer) { HttpStub::Examples::ConfigurerWithEndpointTemplate.new }

    before(:example) { configurer.class.initialize! }

    it "does not register a stub when the template is defined" do
      response = issue_request("template_uri")

      expect(response.code).to eql(404)
    end

    context "and a templated scenario is activated" do

      before(:example) { stub_server.activate!(scenario_name) }

      context "that customises the request matching rules" do

        let(:scenario_name) { "custom_request" }

        let(:response) { issue_request("custom_uri") }

        it "registers a templated stub for the scenario" do
          expect(response.code).to eql(200)
          expect(response.body).to eql("template body")
        end

      end

      context "that customises the response" do

        let(:scenario_name) { "custom_response" }

        let(:response) { issue_request("template_uri") }

        it "registers a templated stub for the scenario" do
          expect(response.code).to eql(202)
          expect(response.body).to eql("custom body")
        end

      end

    end

  end

  def issue_request(uri)
    HTTParty.get("#{server_uri}/#{uri}")
  end

end
