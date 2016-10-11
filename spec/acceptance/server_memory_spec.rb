describe "Server memory acceptance" do

  context "when a configurer with a stub is initialized" do
    include_context "configurer integration with stubs recalled"

    def configurer
      HttpStub::Examples::ConfigurerWithTrivialStub
    end

    describe "GET /http_stub/memory" do

      let(:response) { HTTParty.get("#{server_uri}/http_stub/memory") }

      it "lists the stubs registered during initialization" do
        expect(response.body).to include("Class stub body")
      end

    end

  end

end
