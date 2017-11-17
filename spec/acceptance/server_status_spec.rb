describe "Server status acceptance" do

  describe "GET /http_stub/status" do

    let(:response) { HTTParty.get("#{server_uri}/http_stub/status") }

    context "when a server is started" do
      include_context "server integration"

      let(:configurator) { HttpStub::Examples::ConfiguratorWithTrivialStubs }

      it "indicates the server is available" do
        expect(response.body).to eql("OK")
      end

    end

  end

end
