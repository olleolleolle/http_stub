describe HttpStub::Configurer, "when the server is running" do
  include_context "server integration"

  let(:configurer) { HttpStub::Examples::ConfigurerWithClassActivator.new }

  after(:each) do
    configurer.clear_stubs!
    configurer.class.clear_activators!
  end

  context "and the configurer is initialized" do

    before(:each) do
      configurer.class.host server_host
      configurer.class.port server_port
      configurer.class.initialize!
    end

    context "and a stub is activated" do

      before(:each) { configurer.activate!("/an_activator") }

      context "and the stub request is made" do

        let(:response) { Net::HTTP.get_response(server_host, "/stub_path", server_port) }

        it "should replay the stubbed response" do
          response.code.should eql("200")
          response.body.should eql("Stub activator body")
        end

      end

    end

    context "and a stub is not activated" do

      context "and the stub request is made" do

        let(:response) { Net::HTTP.get_response(server_host, "/stub_path", server_port) }

        it "should respond with a 404 status code" do
          response.code.should eql("404")
        end

      end

    end

    context "and a class stub is defined" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithClassStub.new }

      it "should register the stub" do
        response = Net::HTTP.get_response(server_host, "/a_class_stub", server_port)

        response.code.should eql("201")
        response.body.should eql("Class stub body")
      end

      context "and the stub is overridden" do

        before(:each) do
          configurer.stub_response!("/a_class_stub", method: :get, response: { body: "Other class stub body" })
        end

        context "and the configurer is re-initialized" do

          before(:each) { configurer.class.initialize! }

          it "should re-establish the class stub as having priority" do
            response = Net::HTTP.get_response(server_host, "/a_class_stub", server_port)

            response.code.should eql("201")
            response.body.should eql("Class stub body")
          end

        end

      end

    end

    context "and the initializer contains stub activators that are activated and conventional stubs" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithComplexInitializer.new }

      it "should register the activated activator" do
        response = Net::HTTP.get_response(server_host, "/activated_during_initialization_stub_path", server_port)

        response.code.should eql("200")
        response.body.should eql("Activated during initialization body")
      end

      it "should register the stub" do
        response = Net::HTTP.get_response(server_host, "/stubbed_during_initialization_path", server_port)

        response.code.should eql("200")
        response.body.should eql("Stubbed during initialization body")
      end

      context "and another stub is registered" do

        before(:each) do
          configurer.stub_response!("/another_stub", method: :get, response: { body: "Another stub body" })
        end

        context "and the configurer is reset" do

          before(:each) { configurer.reset! }

          it "should remove the stub registered post-initialization" do
            response = Net::HTTP.get_response(server_host, "/another_stub", server_port)

            response.code.should eql("404")
          end

          it "should retain the activated activator during initialization" do
            response = Net::HTTP.get_response(server_host, "/activated_during_initialization_stub_path", server_port)

            response.code.should eql("200")
            response.body.should eql("Activated during initialization body")
          end

          it "should retain the stub registered during initialization" do
            response = Net::HTTP.get_response(server_host, "/stubbed_during_initialization_path", server_port)

            response.code.should eql("200")
            response.body.should eql("Stubbed during initialization body")
          end

        end

      end

    end

    context "and a response for a request is stubbed" do

      context "that contains no headers or parameters" do

        context "and contains a response status" do

          before(:each) do
            configurer.stub_response!("/stub_with_status", method: :get, response: { status: 201, body: "Stub body" })
          end

          context "and that request is made" do

            let(:response) { Net::HTTP.get_response(server_host, "/stub_with_status", server_port) }

            it "should respond with the stubbed status" do
              response.code.should eql("201")
            end

            it "should replay the stubbed body" do
              response.body.should eql("Stub body")
            end

          end

          context "and the stub is cleared" do

            before(:each) { configurer.clear! }

            context "and the original request is made" do

              let(:response) { Net::HTTP.get_response(server_host, "/stub_with_status", server_port) }

              it "should respond with a 404 status code" do
                response.code.should eql("404")
              end

            end

          end

        end

        context "and does not contain a response status" do

          before(:each) do
            configurer.stub_response!("/stub_without_status", method: :get, response: { body: "Stub body" })
          end

          context "and that request is made" do

            let(:response) { Net::HTTP.get_response(server_host, "/stub_without_status", server_port) }

            it "should respond with the stubbed body" do
              response.body.should eql("Stub body")
            end

          end

          context "and the stub uri is regular expression containing meta characters" do

            before(:each) do
              configurer.stub_response!(/\/stub\/regexp\/\$key=value/, method: :get, response: { body: "Stub body" })
            end

            context "and a request is made whose uri matches the regular expression" do

              let(:response) { Net::HTTP.get_response(server_host, "/match/stub/regexp/$key=value", server_port) }

              it "should respond with the stubbed body" do
                response.body.should eql("Stub body")
              end

            end

            context "and a request is made whose uri does not match the regular expression" do

              let(:response) { Net::HTTP.get_response(server_host, "/stub/no_match/regexp", server_port) }

              it "should respond with a 404 status code" do
                response.code.should eql("404")
              end

            end


          end

        end

      end

      context "that contains headers" do

        context "whose values are strings" do

          before(:each) do
            configurer.stub_response!("/stub_with_headers", method: :get, headers: { key: "value" },
                                      response: { status: 202, body: "Another stub body" })
          end

          context "and that request is made" do

            let(:response) { HTTParty.get("#{server_uri}/stub_with_headers", headers: { "key" => "value" }) }

            it "should replay the stubbed response" do
              response.code.should eql(202)
              response.body.should eql("Another stub body")
            end

          end

          context "and a request with different headers is made" do

            let(:response) { HTTParty.get("#{server_uri}/stub_with_headers", headers: { "key" => "other_value" }) }

            it "should respond with a 404 status code" do
              response.code.should eql(404)
            end

          end

        end

        context "whose values are regular expressions" do

          before(:each) do
            configurer.stub_response!("/stub_with_headers", method: :get, headers: { key: /^match.*/ },
                                      response: { status: 202, body: "Another stub body" })
          end

          context "and a request that matches is made" do

            let(:response) do
              HTTParty.get("#{server_uri}/stub_with_headers", headers: { "key" => "matching_value" })
            end

            it "should replay the stubbed response" do
              response.code.should eql(202)
              response.body.should eql("Another stub body")
            end

          end

          context "and a request that does not match is made" do

            let(:response) do
              HTTParty.get("#{server_uri}/stub_with_headers", headers: { "key" => "does_not_match_value" })
            end

            it "should respond with a 404 status code" do
              response.code.should eql(404)
            end

          end

        end

      end

      context "that contains parameters" do

        context "whose values are strings" do

          before(:each) do
            configurer.stub_response!("/stub_with_parameters", method: :get, parameters: { key: "value" },
                                      response: { status: 202, body: "Another stub body" })
          end

          context "and that request is made" do

            let(:response) { Net::HTTP.get_response(server_host, "/stub_with_parameters?key=value", server_port) }

            it "should replay the stubbed response" do
              response.code.should eql("202")
              response.body.should eql("Another stub body")
            end

          end

          context "and a request with different parameters is made" do

            let(:response) do
              Net::HTTP.get_response(server_host, "/stub_with_parameters?key=another_value", server_port)
            end

            it "should respond with a 404 status code" do
              response.code.should eql("404")
            end

          end

        end

        context "whose values are regular expressions" do

          before(:each) do
            configurer.stub_response!("/stub_with_parameters", method: :get, parameters: { key: /^match.*/ },
                                      response: { status: 202, body: "Another stub body" })
          end

          context "and a request that matches is made" do

            let(:response) do
              Net::HTTP.get_response(server_host, "/stub_with_parameters?key=matching_value", server_port)
            end

            it "should replay the stubbed response" do
              response.code.should eql("202")
              response.body.should eql("Another stub body")
            end

          end

          context "and a request that does not match is made" do

            let(:response) do
              Net::HTTP.get_response(server_host, "/stub_with_parameters?key=does_not_match_value", server_port)
            end

            it "should respond with a 404 status code" do
              response.code.should eql("404")
            end

          end

        end

      end

    end

    context "and the configurer contains an on initialize callback" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithInitializeCallback.new }

      it "should execute the callback" do
        response = Net::HTTP.get_response(server_host, "/stubbed_on_initialize_path", server_port)

        response.code.should eql("200")
        response.body.should eql("Stubbed on initialize body")
      end

    end

  end

  context "and the configurer is uninitialized" do

    context "and the configurer is informed that the server has started" do

      before(:each) { configurer.server_has_started! }

      it "should not initialize the configurer" do
        activation_lambda = lambda { configurer.activate!("/an_activator") }

        activation_lambda.should raise_error(/error occurred activating '\/an_activator'/i)
      end

      context "and an attempt is made to register a stub" do

        before(:each) do
          configurer.stub_response!("/some_stub_path", method: :get, response: { body: "Some stub body"})
        end

        it "should register the stub" do
          response = Net::HTTP.get_response(server_host, "/some_stub_path", server_port)

          response.code.should eql("200")
          response.body.should eql("Some stub body")
        end

      end

      context "and an attempt is made to register a stub with a timeout" do

        before(:each) do
          configurer.stub_response!("/some_stub_path", method: :get, response: {:delay_in_seconds => 2})
        end

        it "should delegate to request pipeline" do
          before = Time.new

          response = Net::HTTP.get_response(server_host, "/some_stub_path", server_port)
          response.code.should eql("200")

          after = Time.now

          (after - before).round().should be >= 2
        end

      end

      describe "and an attempt is made to register a response with a given content type" do

        before(:each) do
          configurer.stub_response!("/some_stub_path", method: :get, response: { body: "Some stub body", content_type: "application/xhtml" })
        end

        it "should register the stub" do
          response = Net::HTTP.get_response("localhost", "/some_stub_path", 8001)
          response.content_type.should eql("application/xhtml")
        end

      end

    end

    context "and the configurer has not been informed that the server has started" do

      context "and an attempt is made to activate a stub" do

        it "should raise an exception indicating an error occurred during activation" do
          activation_lambda = lambda { configurer.activate!("/an_activator") }

          activation_lambda.should raise_error(/error occurred activating '\/an_activator'/i)
        end

      end

    end

    context "and the configurer contains an on initialize callback" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithInitializeCallback.new }

      it "should not execute the callback" do
        response = Net::HTTP.get_response(server_host, "/stubbed_on_initialize_path", server_port)

        response.code.should eql("404")
      end

    end

  end

end
