describe "Server memory acceptance" do
  include_context "server integration"

  let(:configurator) { HttpStub::Examples::ConfiguratorWithScenariosAndStubs }

  context "when a server configured with scenarios and stubs is started" do

    describe "GET /http_stub/memory" do

      let(:response) { HTTParty.get("#{server_uri}/http_stub/memory") }

      it "lists scenarios activated initially" do
        expect(response.body).to include("Activated initially body")
      end

      it "does not list scenario's that are not activated initially" do
        expect(response.body).to_not include("Not activated initially body")
      end

      it "lists stubs" do
        expect(response.body).to include("Stub body")
      end

    end

  end

end
