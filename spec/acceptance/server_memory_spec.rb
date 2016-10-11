describe "Server memory acceptance" do
  include_context "configurer integration"

  context "when a configurer with a stub is initialized" do

    let(:configurer)  { HttpStub::Examples::ConfigurerWithTrivialStub }

    before(:example) { configurer.initialize! }

    describe "GET /http_stub/memory" do

      let(:response) { HTTParty.get("#{server_uri}/http_stub/memory") }

      it "lists the stubs registered during initialization" do
        expect(response.body).to include("Class stub body")
      end

    end

  end

end
