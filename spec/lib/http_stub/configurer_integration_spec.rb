describe HttpStub::Configurer, "when the server is running" do
  include_context "server integration"

  let(:configurer)  { HttpStub::Examples::ConfigurerWithClassActivator.new }
  let(:stub_server) { configurer.stub_server }

  after(:example) do
    configurer.clear_stubs!
    configurer.class.clear_activators!
  end

  context "and the configurer is initialized" do

    before(:example) do
      configurer.class.host(server_host)
      configurer.class.port(server_port)
      configurer.class.initialize!
    end

    context "and a stub is activated" do

      before(:example) { configurer.activate!("/an_activator") }

      context "and the stub request is made" do

        let(:response) { Net::HTTP.get_response(server_host, "/stub_path", server_port) }

        it "replays the stubbed response" do
          expect(response.code).to eql("200")
          expect(response.body).to eql("Stub activator body")
        end

      end

    end

    context "and a stub is not activated" do

      context "and the stub request is made" do

        let(:response) { Net::HTTP.get_response(server_host, "/stub_path", server_port) }

        it "responds with a 404 status code" do
          expect(response.code).to eql("404")
        end

      end

    end

    context "and a class stub is defined" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithClassStub.new }

      it "registers the stub" do
        response = Net::HTTP.get_response(server_host, "/a_class_stub", server_port)

        expect(response.code).to eql("201")
        expect(response.body).to eql("Class stub body")
      end

      context "and the stub is overridden" do

        before(:example) do
          configurer.stub_response!("/a_class_stub", method: :get, response: { body: "Other class stub body" })
        end

        context "and the configurer is re-initialized" do

          before(:example) { configurer.class.initialize! }

          it "re-establishes the class stub as having priority" do
            response = Net::HTTP.get_response(server_host, "/a_class_stub", server_port)

            expect(response.code).to eql("201")
            expect(response.body).to eql("Class stub body")
          end

        end

      end

    end

    context "and the initializer contains stub activators that are activated and conventional stubs" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithComplexInitializer.new }

      it "registers the activated activator" do
        response = Net::HTTP.get_response(server_host, "/activated_during_initialization_stub_path", server_port)

        expect(response.code).to eql("200")
        expect(response.body).to eql("Activated during initialization body")
      end

      it "registers the stub" do
        response = Net::HTTP.get_response(server_host, "/stubbed_during_initialization_path", server_port)

        expect(response.code).to eql("200")
        expect(response.body).to eql("Stubbed during initialization body")
      end

      context "and another stub is registered" do

        before(:example) do
          configurer.stub_response!("/another_stub", method: :get, response: { body: "Another stub body" })
        end

        context "and the servers remembered stubs are recalled" do

          before(:example) { configurer.recall_stubs! }

          it "removes the stub registered post-initialization" do
            response = Net::HTTP.get_response(server_host, "/another_stub", server_port)

            expect(response.code).to eql("404")
          end

          it "retains the activated activator during initialization" do
            response = Net::HTTP.get_response(server_host, "/activated_during_initialization_stub_path", server_port)

            expect(response.code).to eql("200")
            expect(response.body).to eql("Activated during initialization body")
          end

          it "retains the stub registered during initialization" do
            response = Net::HTTP.get_response(server_host, "/stubbed_during_initialization_path", server_port)

            expect(response.code).to eql("200")
            expect(response.body).to eql("Stubbed during initialization body")
          end

        end

      end

    end

    context "and a stub is submitted" do

      context "that contains no headers or parameters" do

        context "and contains a response status" do

          before(:example) do
            configurer.stub_response!("/stub_with_status", method: :get, response: { status: 201, body: "Stub body" })
          end

          context "and that request is made" do

            let(:response) { Net::HTTP.get_response(server_host, "/stub_with_status", server_port) }

            it "responds with the stubbed status" do
              expect(response.code).to eql("201")
            end

            it "replays the stubbed body" do
              expect(response.body).to eql("Stub body")
            end

          end

          context "and stubs are cleared" do

            before(:example) { configurer.clear_stubs! }

            context "and the original request is made" do

              let(:response) { Net::HTTP.get_response(server_host, "/stub_with_status", server_port) }

              it "responds with a 404 status code" do
                expect(response.code).to eql("404")
              end

            end

          end

        end

        context "and does not contain a response status" do

          before(:example) do
            configurer.stub_response!("/stub_without_status", method: :get, response: { body: "Stub body" })
          end

          context "and that request is made" do

            let(:response) { Net::HTTP.get_response(server_host, "/stub_without_status", server_port) }

            it "responds with the stubbed body" do
              expect(response.body).to eql("Stub body")
            end

          end

          context "and the stub uri is regular expression containing meta characters" do

            before(:example) do
              configurer.stub_response!(/\/stub\/regexp\/\$key=value/, method: :get, response: { body: "Stub body" })
            end

            context "and a request is made whose uri matches the regular expression" do

              let(:response) { Net::HTTP.get_response(server_host, "/match/stub/regexp/$key=value", server_port) }

              it "responds with the stubbed body" do
                expect(response.body).to eql("Stub body")
              end

            end

            context "and a request is made whose uri does not match the regular expression" do

              let(:response) { Net::HTTP.get_response(server_host, "/stub/no_match/regexp", server_port) }

              it "responds with a 404 status code" do
                expect(response.code).to eql("404")
              end

            end


          end

        end

      end

      context "that contains headers" do

        context "whose values are strings" do

          before(:example) do
            configurer.stub_response!(
              "/stub_with_headers", method: :get, headers: { key: "value" },
              response: { status: 202, body: "Another stub body" }
            )
          end

          context "and that request is made" do

            let(:response) { HTTParty.get("#{server_uri}/stub_with_headers", headers: { "key" => "value" }) }

            it "replays the stubbed response" do
              expect(response.code).to eql(202)
              expect(response.body).to eql("Another stub body")
            end

          end

          context "and a request with different headers is made" do

            let(:response) { HTTParty.get("#{server_uri}/stub_with_headers", headers: { "key" => "other_value" }) }

            it "responds with a 404 status code" do
              expect(response.code).to eql(404)
            end

          end

        end

        context "whose values are regular expressions" do

          before(:example) do
            configurer.stub_response!(
              "/stub_with_headers", method: :get, headers: { key: /^match.*/ },
              response: { status: 202, body: "Another stub body" }
            )
          end

          context "and a request that matches is made" do

            let(:response) do
              HTTParty.get("#{server_uri}/stub_with_headers", headers: { "key" => "matching_value" })
            end

            it "replays the stubbed response" do
              expect(response.code).to eql(202)
              expect(response.body).to eql("Another stub body")
            end

          end

          context "and a request that does not match is made" do

            let(:response) do
              HTTParty.get("#{server_uri}/stub_with_headers", headers: { "key" => "does_not_match_value" })
            end

            it "responds with a 404 status code" do
              expect(response.code).to eql(404)
            end

          end

        end

      end

      context "that contains parameters" do

        context "whose values are strings" do

          before(:example) do
            configurer.stub_response!("/stub_with_parameters", method: :get, parameters: { key: "value" },
                                      response: { status: 202, body: "Another stub body" })
          end

          context "and that request is made" do

            let(:response) { Net::HTTP.get_response(server_host, "/stub_with_parameters?key=value", server_port) }

            it "replays the stubbed response" do
              expect(response.code).to eql("202")
              expect(response.body).to eql("Another stub body")
            end

          end

          context "and a request with different parameters is made" do

            let(:response) do
              Net::HTTP.get_response(server_host, "/stub_with_parameters?key=another_value", server_port)
            end

            it "responds with a 404 status code" do
              expect(response.code).to eql("404")
            end

          end

        end

        context "whose values are regular expressions" do

          before(:example) do
            configurer.stub_response!(
              "/stub_with_parameters", method: :get, parameters: { key: /^match.*/ },
              response: { status: 202, body: "Another stub body" }
            )
          end

          context "and a request that matches is made" do

            let(:response) do
              Net::HTTP.get_response(server_host, "/stub_with_parameters?key=matching_value", server_port)
            end

            it "replays the stubbed response" do
              expect(response.code).to eql("202")
              expect(response.body).to eql("Another stub body")
            end

          end

          context "and a request that does not match is made" do

            let(:response) do
              Net::HTTP.get_response(server_host, "/stub_with_parameters?key=does_not_match_value", server_port)
            end

            it "responds with a 404 status code" do
              expect(response.code).to eql("404")
            end

          end

        end

        context "whose values indicate the parameters must be omitted" do

          before(:example) do
            configurer.stub_response!(
              "/stub_with_omitted_parameters", method: :get, parameters: { key: :omitted },
              response: { status: 202, body: "Omitted parameter stub body" }
            )
          end

          context "and a request that matches is made" do

            let(:response) { Net::HTTP.get_response(server_host, "/stub_with_omitted_parameters", server_port) }

            it "replays the stubbed response" do
              expect(response.code).to eql("202")
              expect(response.body).to eql("Omitted parameter stub body")
            end

          end

          context "and a request that does not match is made" do

            let(:response) do
              Net::HTTP.get_response(server_host, "/stub_with_omitted_parameters?key=must_be_omitted", server_port)
            end

            it "responds with a 404 status code" do
              expect(response.code).to eql("404")
            end

          end

        end

        context "whose values are numbers" do

          before(:example) do
            configurer.stub_response!("/stub_with_parameters", method: :get, parameters: { key: 88 },
                                      response: { status: 203, body: "Body for parameter number" })
          end

          context "and that request is made" do

            let(:response) { Net::HTTP.get_response(server_host, "/stub_with_parameters?key=88", server_port) }

            it "replays the stubbed response" do
              expect(response.code).to eql("203")
              expect(response.body).to eql("Body for parameter number")
            end

          end

        end

        context "whose values are regular expressions" do

          before(:example) do
            configurer.stub_response!(
              "/stub_with_parameters", method: :get, parameters: { key: /^match.*/ },
              response: { status: 202, body: "Another stub body" }
            )
          end

          context "and a request that matches is made" do

            let(:response) do
              Net::HTTP.get_response(server_host, "/stub_with_parameters?key=matching_value", server_port)
            end

            it "replays the stubbed response" do
              expect(response.code).to eql("202")
              expect(response.body).to eql("Another stub body")
            end

          end

          context "and a request that does not match is made" do

            let(:response) do
              Net::HTTP.get_response(server_host, "/stub_with_parameters?key=does_not_match_value", server_port)
            end

            it "responds with a 404 status code" do
              expect(response.code).to eql("404")
            end

          end

        end

        context "whose values indicate the parameters must be omitted" do

          before(:example) do
            configurer.stub_response!(
              "/stub_with_omitted_parameters", method: :get, parameters: { key: :omitted },
              response: { status: 202, body: "Omitted parameter stub body" }
            )
          end

          context "and a request that matches is made" do

            let(:response) { Net::HTTP.get_response(server_host, "/stub_with_omitted_parameters", server_port) }

            it "replays the stubbed response" do
              expect(response.code).to eql("202")
              expect(response.body).to eql("Omitted parameter stub body")
            end

          end

          context "and a request that does not match is made" do

            let(:response) do
              Net::HTTP.get_response(server_host, "/stub_with_omitted_parameters?key=must_be_omitted", server_port)
            end

            it "responds with a 404 status code" do
              expect(response.code).to eql("404")
            end

          end

        end

      end

      context "that contains triggers" do

        let(:triggered_stubs) do
          (1..3).map do |trigger_number|
            stub_server.build_stub do |stub|
              stub.match_requests("/triggered_stub_#{trigger_number}", method: :get)
              stub.respond_with(status: 200 + trigger_number, body: "Triggered stub body #{trigger_number}")
            end
          end
        end

        before(:example) do
          stub_server.add_stub! do |stub|
            stub.match_requests("/stub_with_triggers", method: :get)
            stub.respond_with(body: "Trigger stub body")
            stub.trigger(triggered_stubs)
          end
        end

        context "and a request is made matching the stub" do

          before(:example) do
            @stub_with_triggers_response = Net::HTTP.get_response(server_host, "/stub_with_triggers", server_port)
          end

          it "replays the stubbed response" do
            expect(@stub_with_triggers_response.code).to eql("200")
            expect(@stub_with_triggers_response.body).to eql("Trigger stub body")
          end

          (1..3).each do |trigger_number|

            context "and then a request matching triggered stub ##{trigger_number} is made" do

              let(:response) { Net::HTTP.get_response(server_host, "/triggered_stub_#{trigger_number}", server_port) }

              it "replays the triggered response" do
                expect(response.code).to eql("20#{trigger_number}")
                expect(response.body).to eql("Triggered stub body #{trigger_number}")
              end

            end

          end

        end

      end

    end

    context "and the configurer contains an on initialize callback" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithInitializeCallback.new }

      it "executes the callback" do
        response = Net::HTTP.get_response(server_host, "/stubbed_on_initialize_path", server_port)

        expect(response.code).to eql("200")
        expect(response.body).to eql("Stubbed on initialize body")
      end

    end

  end

  context "and the configurer is uninitialized" do

    context "and the configurer is informed that the server has started" do

      before(:example) { configurer.server_has_started! }

      it "does not initialize the configurer" do
        activation_lambda = lambda { configurer.activate!("/an_activator") }

        expect(activation_lambda).to raise_error(/error occurred activating '\/an_activator'/i)
      end

      context "and an attempt is made to register a stub" do

        before(:example) do
          configurer.stub_response!("/some_stub_path", method: :get, response: { body: "Some stub body"})
        end

        it "registers the stub" do
          response = Net::HTTP.get_response(server_host, "/some_stub_path", server_port)

          expect(response.code).to eql("200")
          expect(response.body).to eql("Some stub body")
        end

      end

      context "and an attempt is made to register a stub with a timeout" do

        before(:example) do
          configurer.stub_response!("/some_stub_path", method: :get, response: {:delay_in_seconds => 2})
        end

        it "delegates to request pipeline" do
          before = Time.new

          response = Net::HTTP.get_response(server_host, "/some_stub_path", server_port)
          expect(response.code).to eql("200")

          after = Time.now

          expect((after - before).round()).to be >= 2
        end

      end

      describe "and an attempt is made to register a response with a content type header" do

        before(:example) do
          configurer.stub_response!(
            "/some_stub_path", method: :get, response: { body: "Some stub body",
                                                         headers: { "content-type" => "application/xhtml" } }
          )
        end

        it "registers the stub" do
          response = Net::HTTP.get_response("localhost", "/some_stub_path", 8001)

          expect(response.content_type).to eql("application/xhtml")
        end

      end

      describe "and an attempt is made to register a response with a other headers" do

        let(:response_headers) do
          {
            "some_header" => "some value",
            "another_header" => "another value",
            "yet_another_header" => "yet another value"
          }
        end

        before(:example) do
          configurer.stub_response!(
            "/some_stub_path", method: :get, response: { body: "Some stub body", headers: response_headers }
          )
        end

        it "registers the stub" do
          response = Net::HTTP.get_response("localhost", "/some_stub_path", 8001)

          response_headers.each { |key, value| expect(response[key]).to eql(value) }
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
        response = Net::HTTP.get_response(server_host, "/stubbed_on_initialize_path", server_port)

        expect(response.code).to eql("404")
      end

    end

  end

end
