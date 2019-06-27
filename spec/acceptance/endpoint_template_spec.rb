describe "Endpoint template acceptance" do

  context "when a server configured with an endpoint template is started" do
    include_context "server integration"

    let(:configurator) { HttpStub::Examples::ConfiguratorWithEndpointTemplate }

    it "does not register a stub when the template is defined" do
      response = issue_request("template_uri")

      expect(response.code).to eql(404)
    end

    it "registers any stubs added to the template" do
      response = issue_request("custom_stub_uri")

      expect(response.code).to eql(201)
      expect(response.body).to eql("custom stub body")
    end

    it "registers any stubs for templated scenarios initially activated" do
      response = issue_request("scenario_initially_activated")

      expect(response.code).to eql(202)
      expect(response.body).to eql("scenario initially activated body")
    end

    context "and a templated scenario is activated" do

      before(:example) { client.activate!(scenario_name) }

      context "that customises the request matching rules" do

        let(:scenario_name) { "Custom request" }

        let(:response) { issue_request("custom_scenario_uri") }

        it "registers a templated stub for the scenario" do
          expect(response.code).to eql(200)
          expect(response.body).to eql("template body")
        end

      end

      context "that customises the response" do

        let(:scenario_name) { "Custom response" }

        let(:response) { issue_request("template_uri") }

        it "registers a templated stub for the scenario" do
          expect(response.code).to eql(202)
          expect(response.body).to eql("custom scenario body")
        end

      end

    end

  end

  def issue_request(uri)
    HTTParty.get("#{server_uri}/#{uri}")
  end

end
