describe "Configurer initialization acceptance" do
  include_context "configurer integration"

  let(:configurer) { HttpStub::Examples::ConfigurerWithTrivialStub }

  context "when a configurer is initialized" do

    before(:example) { configurer.initialize! }

    context "that contains a stub" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithTrivialStub }

      it "registers the stub" do
        response = HTTParty.get("#{server_uri}/a_class_stub")

        expect(response.code).to eql(201)
        expect(response.body).to eql("Class stub body")
      end

      context "and another stub is registered" do

        before(:example) do
          stub_server.add_stub! do |stub|
            stub.match_requests(uri: "/another_stub", method: :get)
            stub.respond_with(body: "Another stub body")
          end
        end

        context "and the servers stubs are recalled" do

          before(:example) { stub_server.recall_stubs! }

          it "removes the stub just registered" do
            response = HTTParty.get("#{server_uri}/another_stub")

            expect(response.code).to eql(404)
          end

          it "retains the stub registered during initialization" do
            response = HTTParty.get("#{server_uri}/a_class_stub")

            expect(response.code).to eql(201)
            expect(response.body).to eql("Class stub body")
          end

        end

      end

      context "and the stub is overridden" do

        before(:example) do
          stub_server.add_stub! do |stub|
            stub.match_requests(uri: "/a_class_stub", method: :get)
            stub.respond_with(body: "Other class stub body")
          end
        end

        context "and the servers stubs are recalled" do

          before(:example) { stub_server.recall_stubs! }

          it "re-establishes the class stub" do
            response = HTTParty.get("#{server_uri}/a_class_stub")

            expect(response.code).to eql(201)
            expect(response.body).to eql("Class stub body")
          end

        end

      end

    end

    context "and the configurer contains an initialize callback" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithInitializeCallback }

      it "executes the callback" do
        response = HTTParty.get("#{server_uri}/stubbed_on_initialize_path")

        expect(response.code).to eql(200)
        expect(response.body).to eql("Stubbed on initialize body")
      end

    end

  end

  context "when a configurer is uninitialized" do

    context "and the configurer is informed that the server has started" do

      before(:example) { stub_server.has_started! }

      it "does not initialize the configurer" do
        expect { stub_server.activate!("an_activator") }.to raise_error(/error occurred activating 'an_activator'/i)
      end

      context "and an attempt is made to register a stub" do

        before(:example) do
          stub_server.add_stub! do
            match_requests(uri: "/some_stub_path", method: :get).respond_with(body: "Some stub body")
          end
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
          expect { stub_server.activate!("an_activator") }.to raise_error(/error occurred activating 'an_activator'/i)
        end

      end

    end

    context "and the configurer contains an initialize callback" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithInitializeCallback }

      it "does not execute the callback" do
        response = HTTParty.get("#{server_uri}/stubbed_on_initialize_path")

        expect(response.code).to eql(404)
      end

    end

  end

end
