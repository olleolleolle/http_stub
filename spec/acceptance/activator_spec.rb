describe "Stub activator acceptance" do
  include_context "configurer integration"

  context "when a configurer that contains a stub activator is initialised" do

    let(:configurer) { HttpStub::Examples::ConfigurerWithDeprecatedActivator.new }

    before(:example) { configurer.class.initialize! }

    context "and the stub is activated" do

      context "and the response contains text" do

        before(:example) { configurer.activate!("/an_activator") }

        context "and the stub request is made" do

          let(:response) { HTTParty.get("#{server_uri}/stub_path") }

          it "replays the stubbed response" do
            expect(response.code).to eql(200)
            expect(response.body).to eql("Stub activator body")
          end

        end

      end

    end

    context "and a stub is not activated" do

      context "and the stub request is made" do

        let(:response) { HTTParty.get("#{server_uri}/stub_path") }

        it "responds with a 404 status code" do
          expect(response.code).to eql(404)
        end

      end

    end

    context "and initialization activates activators" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithComplexInitializer.new }

      it "registers the activated activator" do
        response = HTTParty.get("#{server_uri}/activated_during_initialization_stub_path")

        expect(response.code).to eql(200)
        expect(response.body).to eql("Activated during initialization body")
      end

      context "and another stub is registered" do

        before(:example) do
          configurer.stub_response!("/another_stub", method: :get, response: { body: "Another stub body" })
        end

        context "and the servers remembered stubs are recalled" do

          before(:example) { configurer.recall_stubs! }

          it "retains the activated activator during initialization" do
            response = HTTParty.get("#{server_uri}/activated_during_initialization_stub_path")

            expect(response.code).to eql(200)
            expect(response.body).to eql("Activated during initialization body")
          end

        end

      end

    end

  end

end
