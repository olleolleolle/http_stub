describe HttpStub::Server::Application::Routes::Stub, "when an initialized server is running" do
  include_context "server integration"

  let(:response_document) { Nokogiri::HTML(response.body) }

  before(:example) { initialize_server }

  describe "POST /http_stub/stubs" do

    context "when provided with the minimum data required" do

      let(:response) do
        HTTParty.post(
          "#{server_uri}/http_stub/stubs",
          body: { uri: "/some/path", method: "get", response: { status: 200, body: "Some body" } }.to_json
        )
      end

      after(:example) { reset_session }

      it "returns a 200 response code" do
        expect(response.code).to eql(200)
      end

      it "registers a stub returning the provided response for a matching request" do
        response

        stubbed_response = HTTParty.get("#{server_uri}/some/path")

        expect(stubbed_response.code).to eql(200)
        expect(stubbed_response.body).to eql("Some body")
      end

    end

  end

  describe "and a configurer with multiple scenarios is initialized" do
    include_context "configurer integration"

    let(:configurer_specification) { { class: HttpStub::Examples::ConfigurerWithExhaustiveScenarios } }

    describe "GET /http_stub/stubs" do

      describe "when multiple stubs are configured" do

        before(:example) do
          (1..3).each do |i|
            HTTParty.post("#{server_uri}/http_stub/scenarios/activate", :body => { name: "Scenario #{i}" })
          end
        end

        let(:response) { HTTParty.get("#{server_uri}/http_stub/stubs") }

        it "returns a 200 response code" do
          expect(response.code).to eql(200)
        end

        it "returns a response whose body contains the uri of each stub" do
          (1..3).each do |stub_number|
            expect(response.body).to match(/#{escape_html("/path_#{stub_number}")}/)
          end
        end

        it "returns a response whose body contains the uri of each stub trigger" do
          (1..3).each do |stub_number|
            (1..3).each do |trigger_number|
              expect(response.body).to match(/#{escape_html("/path_#{stub_number}_trigger_#{trigger_number}")}/)
            end
          end
        end

        it "returns a response whose body contains the request headers of each stub" do
          (1..3).each do |stub_number|
            expect(response.body).to match(/request_header_#{stub_number}:request_header_value_#{stub_number}/)
          end
        end

        it "returns a response whose body contains the request headers of each stub trigger" do
          (1..3).each do |stub_number|
            (1..3).each do |trigger_number|
              expected_header_key   = "request_header_#{stub_number}_trigger_#{trigger_number}"
              expected_header_value = "request_header_value_#{stub_number}_trigger_#{trigger_number}"
              expect(response.body).to match(/#{expected_header_key}:#{expected_header_value}/)
            end
          end
        end

        it "returns a response whose body contains the parameters of each stub" do
          (1..3).each do |stub_number|
            expect(response.body).to match(/parameter_#{stub_number}=parameter_value_#{stub_number}/)
          end
        end

        it "returns a response whose body contains the parameters of each stub trigger" do
          (1..3).each do |stub_number|
            (1..3).each do |trigger_number|
              expected_parameter_key   = "parameter_#{stub_number}_trigger_#{trigger_number}"
              expected_parameter_value = "parameter_value_#{stub_number}_trigger_#{trigger_number}"
              expect(response.body).to match(/#{expected_parameter_key}=#{expected_parameter_value}/)
            end
          end
        end

        it "returns a response whose body contains the bodies of each stub" do
          (1..3).each do |stub_number|
            expect(response.body).to(
              match(/#{escape_html("\"property_#{stub_number}\":{\"type\":\"property_#{stub_number}_type\"")}/)
            )
          end
        end

        it "returns a response whose body contains the bodies of each stub trigger" do
          (1..3).each do |stub_number|
            (1..3).each do |trigger_number|
              expected_property_name = "property_#{stub_number}_trigger_#{trigger_number}"
              expected_property_type = "property_#{stub_number}_trigger_#{trigger_number}_type"
              expect(response.body).to(
                match(/#{escape_html("\"#{expected_property_name}\":{\"type\":\"#{expected_property_type}\"")}/)
              )
            end
          end
        end

        it "returns a response whose body contains the response status of each stub" do
          (1..3).each { |stub_number| expect(response.body).to match(/20#{stub_number}/) }
        end

        it "returns a response whose body contains the response status of each stub trigger" do
          (1..3).each do |stub_number|
            (1..3).each do |trigger_number|
              expect(response.body).to match(/30#{stub_number * trigger_number}/)
            end
          end
        end

        it "returns a response whose body contains the response headers of each stub" do
          (1..3).each do |stub_number|
            expected_header_key   = "response_header_#{stub_number}"
            expected_header_value = "response_header_value_#{stub_number}"
            expect(response.body).to match(/#{expected_header_key}:#{expected_header_value}/)
          end
        end

        it "returns a response whose body contains the response headers of each stub trigger" do
          (1..3).each do |stub_number|
            (1..3).each do |trigger_number|
              expected_header_key   = "response_header_#{stub_number}_trigger_#{trigger_number}"
              expected_header_value = "response_header_value_#{stub_number}_trigger_#{trigger_number}"
              expect(response.body).to match(/#{expected_header_key}:#{expected_header_value}/)
            end
          end
        end

        it "returns a response whose body contains the response body of stub returning JSON" do
          expect(response.body).to match(/#{encode_whitespace(JSON.pretty_generate({ key: "JSON body" }))}/)
        end

        it "returns a response whose body contains the response body of stub returning HTML" do
          expect(response.body).to match(/#{encode_whitespace("<html><body>HTML body</body></html>")}/)
        end

        it "returns a response whose body contains the response body of a stub returning a file" do
          file_link = response_document.css("a.file").first
          expect(file_link["href"]).to match(/^file:\/\/[^']+\.pdf$/)
        end

        it "returns a response whose body contains the response body of each stub trigger" do
          (1..3).each do |stub_number|
            (1..3).each do |trigger_number|
              expect(response.body).to match(/Body of scenario stub #{stub_number}_trigger_#{trigger_number}/)
            end
          end
        end

        it "returns a response whose body contains the response delay of each stub" do
          (1..3).each { |stub_number| expect(response.body).to include("#{8 * stub_number}") }
        end

        it "returns a response whose body contains the response delay of each stub trigger" do
          (1..3).each do |stub_number|
            (1..3).each do |trigger_number|
              expect(response.body).to include("#{3 * stub_number * trigger_number}")
            end
          end
        end

      end

    end

    describe "GET /http_stub/scenarios" do

      let(:response) { HTTParty.get("#{server_uri}/http_stub/scenarios") }

      let(:transactional_session_parameter) { "http_stub_session_id=#{transactional_session_id}" }

      it "returns a response whose body contains the name of each scenario in alphabetical order" do
        expected_scenario_names = [ "Nested scenario", "Scenario" ].map do |scenario_name_prefix|
          (1..3).map { |i| "#{scenario_name_prefix} #{i}" }
        end.flatten

        scenario_names = response_document.css(".scenario_name").map { |element| element.text }

        expect(scenario_names).to eql(expected_scenario_names)
      end

      it "returns a response whose body contains links to activate each scenario in the transactional session" do
        expected_activation_links = [ "/http_stub/scenarios/activate?#{transactional_session_parameter}" ] * 6

        activation_links = response_document.css("a.activate_scenario").map { |link| link["href"] }

        expect(activation_links).to eql(expected_activation_links)
      end

      it "returns a response whose body contains links to the details of each scenario for the default session" do
        expected_detail_links = %w{ Nested+scenario Scenario }.map do |scenario_name_prefix|
          (1..3).map { |i| "/http_stub/scenarios?name=#{scenario_name_prefix}+#{i}&#{transactional_session_parameter}" }
        end.flatten

        detail_links = response_document.css("a.view_scenario").map { |link| link["href"] }

        expect(detail_links).to eql(expected_detail_links)
      end

    end

    describe "GET /http/scenario?name" do

      (1..3).each do |stub_number|

        scenario_name = "Scenario #{stub_number}"

        context "when the scenario with the name '#{scenario_name}' is requested" do

          let(:response) do
            HTTParty.get("#{server_uri}/http_stub/scenarios?#{URI.encode_www_form(:name => scenario_name)}")
          end

          it "should have a detail page for the scenario" do
            expect(response.code).to eql(200)
          end

          it "returns a response whose body contains the uri of the scenario" do
            expect(response.body).to match(/#{escape_html("/path_#{stub_number}")}/)
          end

          it "returns a response whose body contains the uri of each stub trigger" do
            (1..3).each do |trigger_number|
              expect(response.body).to match(/#{escape_html("/path_#{stub_number}_trigger_#{trigger_number}")}/)
            end
          end

          it "returns a response whose body contains the request headers of each stub" do
            expect(response.body).to match(/request_header_#{stub_number}:request_header_value_#{stub_number}/)
          end

          it "returns a response whose body contains the request headers of each stub trigger" do
            (1..3).each do |trigger_number|
              expected_header_key   = "request_header_#{stub_number}_trigger_#{trigger_number}"
              expected_header_value = "request_header_value_#{stub_number}_trigger_#{trigger_number}"
              expect(response.body).to match(/#{expected_header_key}:#{expected_header_value}/)
            end
          end

          it "returns a response whose body contains the parameters of each stub" do
            expect(response.body).to match(/parameter_#{stub_number}=parameter_value_#{stub_number}/)
          end

          it "returns a response whose body contains the parameters of each stub trigger" do
            (1..3).each do |trigger_number|
              expected_parameter_key   = "parameter_#{stub_number}_trigger_#{trigger_number}"
              expected_parameter_value = "parameter_value_#{stub_number}_trigger_#{trigger_number}"
              expect(response.body).to match(/#{expected_parameter_key}=#{expected_parameter_value}/)
            end
          end

          it "returns a response whose body contains the bodies of each stub" do
            expect(response.body).to(
              match(/#{escape_html("\"property_#{stub_number}\":{\"type\":\"property_#{stub_number}_type\"")}/)
            )
          end

          it "returns a response whose body contains the bodies of each stub trigger" do
            (1..3).each do |trigger_number|
              expected_property_name = "property_#{stub_number}_trigger_#{trigger_number}"
              expected_property_type = "property_#{stub_number}_trigger_#{trigger_number}_type"
              expect(response.body).to(
                match(/#{escape_html("\"#{expected_property_name}\":{\"type\":\"#{expected_property_type}\"")}/)
              )
            end
          end

          it "returns a response whose body contains the response status of each stub" do
            expect(response.body).to match(/20#{stub_number}/)
          end

          it "returns a response whose body contains the response status of each stub trigger" do
            (1..3).each do |trigger_number|
              expect(response.body).to match(/30#{stub_number * trigger_number}/)
            end
          end

          it "returns a response whose body contains the response headers of each stub" do
            expected_header_key   = "response_header_#{stub_number}"
            expected_header_value = "response_header_value_#{stub_number}"
            expect(response.body).to match(/#{expected_header_key}:#{expected_header_value}/)
          end

          it "returns a response whose body contains the response headers of each stub trigger" do
            (1..3).each do |trigger_number|
              expected_header_key   = "response_header_#{stub_number}_trigger_#{trigger_number}"
              expected_header_value = "response_header_value_#{stub_number}_trigger_#{trigger_number}"
              expect(response.body).to match(/#{expected_header_key}:#{expected_header_value}/)
            end
          end

          it "returns a response whose body supports JSON responses" do
            expect(response.body).to match(/#{encode_whitespace(JSON.pretty_generate({ "key" => "JSON body" }))}/)
          end if stub_number == 1

          it "returns a response whose body supports HTML responses" do
            expect(response.body).to match(/#{encode_whitespace("<html><body>HTML body</body></html>")}/)
          end if stub_number == 2

          it "returns a response whose body supports file responses" do
            file_link = response_document.css("a.file").first
            expect(file_link["href"]).to match(/^file:\/\/[^']+\.pdf$/)
          end if stub_number == 3

          it "returns a response whose body contains the response body of each stub trigger" do
            (1..3).each do |trigger_number|
              expect(response.body).to match(/Body of scenario stub #{stub_number}_trigger_#{trigger_number}/)
            end
          end

          it "returns a response whose body contains the response delay of each stub" do
            expect(response.body).to include("#{8 * stub_number}")
          end

          it "returns a response whose body contains the response delay of each stub trigger" do
            (1..3).each do |trigger_number|
              expect(response.body).to include("#{3 * stub_number * trigger_number}")
            end
          end

        end

      end

    end

  end

end
