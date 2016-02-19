describe HttpStub::Server::Application, "when the server is running" do
  include_context "server integration"

  let(:response_document) { Nokogiri::HTML(response.body) }

  describe "POST /stubs" do

    context "when provided with the minimum data required" do

      let(:response) do
        HTTParty.post(
          "#{server_uri}/http_stub/stubs",
          body: { uri: "/some/path", method: "get", response: { status: 200, body: "Some body" } }.to_json
        )
      end

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

    before(:all) do
      configurer = HttpStub::Examples::ConfigurerWithExhaustiveScenarios
      configurer.stub_server.host = server_host
      configurer.stub_server.port = server_port
      configurer.initialize!
    end

    describe "GET /stubs" do

      describe "when multiple stubs are configured" do

        before(:context) { (1..3).each { |i| HTTParty.get("#{server_uri}/scenario_#{i}") } }

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
          expect(response.body).to match(/#{escape_html({ "key" => "JSON body" }.to_json)}/)
        end

        it "returns a response whose body contains the response body of stub returning HTML" do
          expect(response.body).to match(/#{escape_html("<html><body>HTML body</body></html>")}/)
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

      it "returns a response whose body contains links to each scenario in alphabetical order" do
        expected_scenario_links = %w{ nested_scenario scenario }.map do |scenario_name_prefix|
          (1..3).map { |i| ["/#{scenario_name_prefix}_#{i}", "/http_stub/scenarios/#{scenario_name_prefix}_#{i}"] }
        end.flatten

        scenario_links = response_document.css("a.scenario").map { |link| link["href"] }

        expect(scenario_links).to eql(expected_scenario_links)
      end

      it "returns a response whose body contains links to the scenarios triggered by each scenario" do
        response_document.css("a.triggered_scenario").each_with_index do |link, i|
          expect(link["href"]).to eql("/nested_scenario_#{i + 1}")
        end
      end

    end

    describe "GET /http/scenario/:name" do

      scenarios = %w{ nested_scenario scenario }.map do |scenario_name_prefix|
        (1..3).map { |i| "#{scenario_name_prefix}_#{i}" }
      end.flatten

      scenarios.each do |scenario|

        let(:response) { HTTParty.get("#{server_uri}/http_stub/scenarios/#{scenario}") }
        let(:stub_number) { /^[a-z_]+([0-9])$/.match(scenario)[1].to_i }

        it "should have a detail page for each scenario" do
          expect(response.code).to eq 200
        end

        it "returns a response whose body contains the uri of the stub" do
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

        it "returns a response whose body contains the appropriate response type" do
          case stub_number
            when 1
              expect(response.body).to match(/#{escape_html({ "key" => "JSON body" }.to_json)}/)

            when 2
              expect(response.body).to match(/#{escape_html("<html><body>HTML body</body></html>")}/)

            when 3
              file_link = response_document.css("a.file").first
              expect(file_link["href"]).to match(/^file:\/\/[^']+\.pdf$/)
          end
        end

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
