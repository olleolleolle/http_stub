describe "Configurer Part acceptance" do
  include_context "configurer integration"

  context "when a configurer contains a part" do

    let(:configurer) { HttpStub::Examples::ConfigurerWithParts }

    before(:example) { configurer.initialize! }

    context "that contains a configure stub method" do

      let(:response) { issue_request("registered_in_configure_stub_method") }

      it "invokes the method" do
        expect(response.body).to eql("configure stub response")
      end

    end

    context "that contains a configure stubs method" do

      let(:response) { issue_request("registered_in_configure_stubs_method") }

      it "invokes the method" do
        expect(response.body).to eql("configure stubs response")
      end

    end

    context "that contains a configure scenario method" do

      let(:response) { issue_request("registered_in_configure_scenario_method") }

      it "invokes the method" do
        expect(response.body).to eql("configure scenario response")
      end

    end

    context "that contains a configure scenarios method" do

      let(:response) { issue_request("registered_in_configure_scenarios_method") }

      it "invokes the method" do
        expect(response.body).to eql("configure scenarios response")
      end

    end

    context "that contains a part referencing another part" do

      let(:response) { issue_request("registered_in_another_part") }

      it "resolves the other part successfully" do
        expect(response.body).to eql("response from another part")
      end

    end

    def issue_request(uri)
      HTTParty.get("#{server_uri}/#{uri}")
    end

  end

end
