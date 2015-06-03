describe "Configurer initialization acceptance" do
  include_context "configurer integration"

  let(:configurer) { HttpStub::Examples::ConfigurerWithComplexInitializer.new }

  context "when a configurer is initialized" do

    before(:example) { configurer.class.initialize! }

    context "that contains a class stub" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithClassStub.new }

      it "registers the stub" do
        response = HTTParty.get("#{server_uri}/a_class_stub")

        expect(response.code).to eql(201)
        expect(response.body).to eql("Class stub body")
      end

      context "and the stub is overridden" do

        before(:example) do
          configurer.stub_response!("/a_class_stub", method: :get, response: { body: "Other class stub body" })
        end

        context "and the configurer is re-initialized" do

          before(:example) do
            configurer.class.initialize!
          end

          it "re-establishes the class stub as having priority" do
            response = HTTParty.get("#{server_uri}/a_class_stub")

            expect(response.code).to eql(201)
            expect(response.body).to eql("Class stub body")
          end

        end

      end

    end

    context "and the initializer contains conventional stubs" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithComplexInitializer.new }

      it "registers the stub" do
        response = HTTParty.get("#{server_uri}/stubbed_during_initialization_path")

        expect(response.code).to eql(200)
        expect(response.body).to eql("Stubbed during initialization body")
      end

      context "and another stub is registered" do

        before(:example) do
          configurer.stub_response!("/another_stub", method: :get, response: { body: "Another stub body" })
        end

        context "and the servers remembered stubs are recalled" do

          before(:example) { configurer.recall_stubs! }

          it "removes the stub registered post-initialization" do
            response = HTTParty.get("#{server_uri}/another_stub")

            expect(response.code).to eql(404)
          end

          it "retains the stub registered during initialization" do
            response = HTTParty.get("#{server_uri}/stubbed_during_initialization_path")

            expect(response.code).to eql(200)
            expect(response.body).to eql("Stubbed during initialization body")
          end

        end

      end

    end

    context "and the configurer contains an on initialize callback" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithInitializeCallback.new }

      it "executes the callback" do
        response = HTTParty.get("#{server_uri}/stubbed_on_initialize_path")

        expect(response.code).to eql(200)
        expect(response.body).to eql("Stubbed on initialize body")
      end

    end

  end

  context "when a configurer is uninitialized" do

    context "and the configurer is informed that the server has started" do

      before(:example) { configurer.server_has_started! }

      it "does not initialize the configurer" do
        activation_lambda = lambda { configurer.activate!("/an_activator") }

        expect(activation_lambda).to raise_error(/error occurred activating '\/an_activator'/i)
      end

      context "and an attempt is made to register a stub" do

        before(:example) do
          configurer.stub_response!("/some_stub_path", method: :get, response: { body: "Some stub body" })
        end

        it "registers the stub" do
          response = HTTParty.get("#{server_uri}/some_stub_path")

          expect(response.code).to eql(200)
          expect(response.body).to eql("Some stub body")
        end

      end

    end

    context "and the configurer has not been informed that the server has started" do

      context "and an attempt is made to activate a stub" do

        it "raises an exception indicating an error occurred during activation" do
          activation_lambda = lambda { configurer.activate!("/an_activator") }

          expect(activation_lambda).to raise_error(/error occurred activating '\/an_activator'/i)
        end

      end

    end

    context "and the configurer contains an on initialize callback" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithInitializeCallback.new }

      it "does not execute the callback" do
        response = HTTParty.get("#{server_uri}/stubbed_on_initialize_path")

        expect(response.code).to eql(404)
      end

    end

  end

end
