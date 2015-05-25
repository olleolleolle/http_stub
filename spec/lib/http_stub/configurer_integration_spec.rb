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

      context "and the response contains a file" do

        let(:configurer)  { HttpStub::Examples::ConfigurerWithFileResponse.new }

        before(:example) { configurer.activate!("/a_file_activator") }

        context "and the stub request is made" do

          let(:response) { HTTParty.get("#{server_uri}/activated_response_with_file") }

          it "replays the stubbed response" do
            expect(response.code).to eql(200)
            expect_response_to_contain_file(HttpStub::Examples::ConfigurerWithFileResponse::FILE_PATH)
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

    context "and a class stub is defined" do

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

    context "and the initializer contains stub activators that are activated and conventional stubs" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithComplexInitializer.new }

      it "registers the activated activator" do
        response = HTTParty.get("#{server_uri}/activated_during_initialization_stub_path")

        expect(response.code).to eql(200)
        expect(response.body).to eql("Activated during initialization body")
      end

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

          it "retains the activated activator during initialization" do
            response = HTTParty.get("#{server_uri}/activated_during_initialization_stub_path")

            expect(response.code).to eql(200)
            expect(response.body).to eql("Activated during initialization body")
          end

          it "retains the stub registered during initialization" do
            response = HTTParty.get("#{server_uri}/stubbed_during_initialization_path")

            expect(response.code).to eql(200)
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

            let(:response) { HTTParty.get("#{server_uri}/stub_with_status") }

            it "responds with the stubbed status" do
              expect(response.code).to eql(201)
            end

            it "replays the stubbed body" do
              expect(response.body).to eql("Stub body")
            end

          end

          context "and stubs are cleared" do

            before(:example) { configurer.clear_stubs! }

            context "and the original request is made" do

              let(:response) { HTTParty.get("#{server_uri}/stub_with_status") }

              it "responds with a 404 status code" do
                expect(response.code).to eql(404)
              end

            end

          end

        end

        context "and does not contain a response status" do

          before(:example) do
            configurer.stub_response!("/stub_without_status", method: :get, response: { body: "Stub body" })
          end

          context "and that request is made" do

            let(:response) { HTTParty.get("#{server_uri}/stub_without_status") }

            it "responds with the stubbed body" do
              expect(response.body).to eql("Stub body")
            end

          end

          context "and the stub uri is regular expression containing meta characters" do

            before(:example) do
              configurer.stub_response!(/\/stub\/regexp\/\$key=value/, method: :get, response: { body: "Stub body" })
            end

            context "and a request is made whose uri matches the regular expression" do

              let(:response) { HTTParty.get("#{server_uri}/match/stub/regexp/$key=value") }

              it "responds with the stubbed body" do
                expect(response.body).to eql("Stub body")
              end

            end

            context "and a request is made whose uri does not match the regular expression" do

              let(:response) { HTTParty.get("#{server_uri}/stub/no_match/regexp") }

              it "responds with a 404 status code" do
                expect(response.code).to eql(404)
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

            let(:response) { HTTParty.get("#{server_uri}/stub_with_parameters?key=value") }

            it "replays the stubbed response" do
              expect(response.code).to eql(202)
              expect(response.body).to eql("Another stub body")
            end

          end

          context "and a request with different parameters is made" do

            let(:response) { HTTParty.get("#{server_uri}/stub_with_parameters?key=another_value") }

            it "responds with a 404 status code" do
              expect(response.code).to eql(404)
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

            let(:response) { HTTParty.get("#{server_uri}/stub_with_parameters?key=matching_value") }

            it "replays the stubbed response" do
              expect(response.code).to eql(202)
              expect(response.body).to eql("Another stub body")
            end

          end

          context "and a request that does not match is made" do

            let(:response) { HTTParty.get("#{server_uri}/stub_with_parameters?key=does_not_match_value") }

            it "responds with a 404 status code" do
              expect(response.code).to eql(404)
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

            let(:response) { HTTParty.get("#{server_uri}/stub_with_omitted_parameters") }

            it "replays the stubbed response" do
              expect(response.code).to eql(202)
              expect(response.body).to eql("Omitted parameter stub body")
            end

          end

          context "and a request that does not match is made" do

            let(:response) { HTTParty.get("#{server_uri}/stub_with_omitted_parameters?key=must_be_omitted") }

            it "responds with a 404 status code" do
              expect(response.code).to eql(404)
            end

          end

        end

        context "whose values are numbers" do

          before(:example) do
            configurer.stub_response!("/stub_with_parameters", method: :get, parameters: { key: 88 },
                                      response: { status: 203, body: "Body for parameter number" })
          end

          context "and that request is made" do

            let(:response) { HTTParty.get("#{server_uri}/stub_with_parameters?key=88") }

            it "replays the stubbed response" do
              expect(response.code).to eql(203)
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

            let(:response) { HTTParty.get("#{server_uri}/stub_with_parameters?key=matching_value") }

            it "replays the stubbed response" do
              expect(response.code).to eql(202)
              expect(response.body).to eql("Another stub body")
            end

          end

          context "and a request that does not match is made" do

            let(:response) { HTTParty.get("#{server_uri}/stub_with_parameters?key=does_not_match_value") }

            it "responds with a 404 status code" do
              expect(response.code).to eql(404)
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

            let(:response) { HTTParty.get("#{server_uri}/stub_with_omitted_parameters") }

            it "replays the stubbed response" do
              expect(response.code).to eql(202)
              expect(response.body).to eql("Omitted parameter stub body")
            end

          end

          context "and a request that does not match is made" do

            let(:response) { HTTParty.get("#{server_uri}/stub_with_omitted_parameters?key=must_be_omitted") }

            it "responds with a 404 status code" do
              expect(response.code).to eql(404)
            end

          end

        end

      end

      context "that contains triggers with simple response bodies" do

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

          before(:example) { @stub_with_triggers_response = HTTParty.get("#{server_uri}/stub_with_triggers") }

          it "replays the stubbed response" do
            expect(@stub_with_triggers_response.code).to eql(200)
            expect(@stub_with_triggers_response.body).to eql("Trigger stub body")
          end

          (1..3).each do |trigger_number|

            context "and then a request matching triggered stub ##{trigger_number} is made" do

              let(:response) { HTTParty.get("#{server_uri}/triggered_stub_#{trigger_number}") }

              it "replays the triggered response" do
                expect(response.code).to eql("20#{trigger_number}".to_i)
                expect(response.body).to eql("Triggered stub body #{trigger_number}")
              end

            end

          end

        end

      end

      context "that contains triggers with a mix of file and text responses" do

        let(:pdf_file_path) { "#{HttpStub::Spec::RESOURCES_DIR}/sample.pdf" }
        let(:pdf_file_trigger) do
          stub_server.build_stub do |stub|
            stub.match_requests("/triggered_stub_pdf_file", method: :get)
            stub.respond_with(
              status: 201,
              headers: { "content-type" => "application/pdf" },
              body: { file: { path: pdf_file_path, name: ::File.basename(pdf_file_path) } }
            )
          end
        end

        let(:text_body) { "Sample trigger stub body" }
        let(:text_trigger) do
          stub_server.build_stub do |stub|
            stub.match_requests("/triggered_stub_text", method: :get)
            stub.respond_with(status: 202, body: "Sample trigger stub body")
          end
        end

        let(:txt_file_path) { "#{HttpStub::Spec::RESOURCES_DIR}/sample.txt" }
        let(:txt_file_trigger) do
          stub_server.build_stub do |stub|
            stub.match_requests("/triggered_stub_txt_file", method: :get)
            stub.respond_with(
              status: 203,
              headers: { "content-type" => "text/plain" },
              body: { file: { path: txt_file_path, name: ::File.basename(txt_file_path) } }
            )
          end
        end

        let(:triggered_stubs) { [ pdf_file_trigger, text_trigger, txt_file_trigger ] }

        before(:example) do
          stub_server.add_stub! do |stub|
            stub.match_requests("/stub_with_triggers", method: :get)
            stub.respond_with(body: "Trigger stub body")
            stub.trigger(triggered_stubs)
          end
        end

        context "and a request is made matching the stub" do

          before(:example) { HTTParty.get("#{server_uri}/stub_with_triggers") }

          context "and then a request matching a triggered stub returning a PDF file is made" do

            let(:response) { HTTParty.get("#{server_uri}/triggered_stub_pdf_file") }

            it "replays the triggered response" do
              expect(response.code).to eql(201)
              expect_response_to_contain_file(pdf_file_path)
            end

          end

          context "and then a request matching a triggered stub returning texrt is made" do

            let(:response) { HTTParty.get("#{server_uri}/triggered_stub_text") }

            it "replays the triggered response" do
              expect(response.code).to eql(202)
              expect(response.body).to eql(text_body)
            end

          end

          context "and then a request matching a triggered stub returning a text file is made" do

            let(:response) { HTTParty.get("#{server_uri}/triggered_stub_txt_file") }

            it "replays the triggered response" do
              expect(response.code).to eql(203)
              expect(response.parsed_response).to eql(::File.read(txt_file_path))
            end

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

    context "and the configurer declares response defaults" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithResponseDefaults.new }

      it "includes the defaults in each response" do
        response = Net::HTTP.get_response(server_host, "/response_with_defaults", server_port)

        expect(response["defaulted_header"]).to eql("Header value")
      end

    end

    context "and the configurer stubs responses with a file body" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithFileResponse.new }

      context "and a request that matches is made" do

        context "that matches a stub with a custom content-type" do

          let(:response) { HTTParty.get("#{server_uri}/stub_response_with_file") }

          it "responds with the configured status code" do
            expect(response.code).to eql(200)
          end

          it "responds with the configured content type" do
            expect(response.content_type).to eql("application/pdf")
          end

          it "responds with the configured file" do
            expect_response_to_contain_file(HttpStub::Examples::ConfigurerWithFileResponse::FILE_PATH)
          end

        end

        context "that matches a stub with no content-type" do

          let(:response) { HTTParty.get("#{server_uri}/stub_response_with_file_and_no_content_type") }

          it "responds with a default content type of 'application/octet-stream'" do
            expect(response.content_type).to eql("application/octet-stream")
          end

          it "responds with the configured response" do
            expect_response_to_contain_file(HttpStub::Examples::ConfigurerWithFileResponse::FILE_PATH)
          end

        end

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
          configurer.stub_response!("/some_stub_path", method: :get, response: { body: "Some stub body" })
        end

        it "registers the stub" do
          response = HTTParty.get("#{server_uri}/some_stub_path")

          expect(response.code).to eql(200)
          expect(response.body).to eql("Some stub body")
        end

      end

      context "and an attempt is made to register a stub with a timeout" do

        before(:example) do
          configurer.stub_response!("/some_stub_path", method: :get, response: { delay_in_seconds: 2 })
        end

        it "delegates to request pipeline" do
          before = Time.new

          response = HTTParty.get("#{server_uri}/some_stub_path")
          expect(response.code).to eql(200)

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
          response = HTTParty.get("#{server_uri}/some_stub_path")

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
        response = HTTParty.get("#{server_uri}/stubbed_on_initialize_path")

        expect(response.code).to eql(404)
      end

    end

  end

  def expect_response_to_contain_file(path)
    response_file = Tempfile.new(File.basename(path)).tap do |file|
      file.write(response.parsed_response)
      file.flush
    end
    expect(FileUtils.compare_file(path, response_file.path)).to be(true)
  end

end
