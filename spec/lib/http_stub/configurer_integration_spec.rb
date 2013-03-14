describe HttpStub::Configurer, "when the server is running" do
  include_context "server integration"

  let(:configurer) { HttpStub::Examples::ConfigurerWithClassActivator.new }

  after(:each) do
    configurer.clear_stubs!
    configurer.class.clear_activators!
  end

  describe "and the configurer is initialized" do

    before(:each) { configurer.class.initialize! }

    describe "and a stub is activated" do

      before(:each) { configurer.activate!("/an_activator") }

      describe "and the stub request is made" do

        let(:response) { Net::HTTP.get_response("localhost", "/stub_path", 8001) }

        it "should replay the stubbed response" do
          response.code.should eql("200")
          response.body.should eql("Stub activator body")
        end

      end

    end

    describe "and a stub is not activated" do

      describe "and the stub request is made" do

        let(:response) { Net::HTTP.get_response("localhost", "/stub_path", 8001) }

        it "should respond with a 404 status code" do
          response.code.should eql("404")
        end

      end

    end

    describe "and an class stub is defined" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithClassStub.new }

      it "the stub should be registered" do
        response = Net::HTTP.get_response("localhost", "/a_class_stub", 8001)

        response.code.should eql("201")
        response.body.should eql("Class stub body")
      end

    end

    describe "and a response for a request is stubbed" do

      describe "that contains no headers or parameters" do

        describe "and contains a response status" do

          before(:each) do
            configurer.stub_response!("/stub_with_status", method: :get, response: { status: 201, body: "Stub body" })
          end

          describe "and that request is made" do

            let(:response) { Net::HTTP.get_response("localhost", "/stub_with_status", 8001) }

            it "should respond with the stubbed status" do
              response.code.should eql("201")
            end

            it "should replay the stubbed body" do
              response.body.should eql("Stub body")
            end

          end

          describe "and the stub is cleared" do

            before(:each) { configurer.clear! }

            describe "and the original request is made" do

              let(:response) { Net::HTTP.get_response("localhost", "/stub_with_status", 8001) }

              it "should respond with a 404 status code" do
                response.code.should eql("404")
              end

            end

          end

        end

        describe "and does not contain a response status" do

          before(:each) do
            configurer.stub_response!("/stub_without_status", method: :get, response: { body: "Stub body" })
          end

          describe "and that request is made" do

            let(:response) { Net::HTTP.get_response("localhost", "/stub_without_status", 8001) }

            it "should respond with the stubbed body" do
              response.body.should eql("Stub body")
            end

          end

        end

      end

      describe "that contains headers" do

        before(:each) do
          configurer.stub_response!("/stub_with_headers", method: :get, headers: { key: "value" },
                                    response: { status: 202, body: "Another stub body" })
        end

        describe "and that request is made" do

          let(:response) { HTTParty.get("http://localhost:8001/stub_with_headers", headers: { "key" => "value" }) }

          it "should replay the stubbed response" do
            response.code.should eql(202)
            response.body.should eql("Another stub body")
          end

        end

        describe "and a request with different headers is made" do

          let(:response) { HTTParty.get("http://localhost:8001/stub_with_headers", headers: { "key" => "other_value" }) }

          it "should respond with a 404 status code" do
            response.code.should eql(404)
          end

        end

      end

      describe "that contains parameters" do

        before(:each) do
          configurer.stub_response!("/stub_with_parameters", method: :get, parameters: { key: "value" },
                                    response: { status: 202, body: "Another stub body" })
        end

        describe "and that request is made" do

          let(:response) { Net::HTTP.get_response("localhost", "/stub_with_parameters?key=value", 8001) }

          it "should replay the stubbed response" do
            response.code.should eql("202")
            response.body.should eql("Another stub body")
          end

        end

        describe "and a request with different parameters is made" do

          let(:response) { Net::HTTP.get_response("localhost", "/stub_with_parameters?key=another_value", 8001) }

          it "should respond with a 404 status code" do
            response.code.should eql("404")
          end

        end

      end

    end

  end

  describe "and the configurer is uninitialized" do

    describe "and an attempt is made to activate a stub" do

      let(:response) { Net::HTTP.get_response("localhost", "/stub_path", 8001) }

      it "should raise an exception indicating an error occurred during activation" do
        activation_lambda = lambda { configurer.activate!("/an_activator") }

        activation_lambda.should raise_error(/error occurred activating '\/an_activator'/i)
      end

    end

  end

end
