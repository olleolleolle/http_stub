describe "Server status acceptance" do

  describe "GET /http_stub/status" do

    let(:response) { HTTParty.get("#{server_uri}/http_stub/status") }

    context "when a server is started without a configurer" do
      include_context "server integration"

      it "indicates the server has started" do
        expect(response.body).to eql("Started")
      end

      context "and the server is updated to reflect it is initialized" do

        before(:example) { HTTParty.post("#{server_uri}/http_stub/status/initialized") }

        it "indicates the server has been initialized" do
          expect(response.body).to eql("Initialized")
        end

      end

    end

    context "when a server with a configurer is started" do
      include_context "configurer integration"

      it "indicates the server has been initialized" do
        expect(response.body).to eql("Initialized")
      end

    end

  end

end
