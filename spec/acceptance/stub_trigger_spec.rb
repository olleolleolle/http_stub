describe "Stub trigger acceptance" do
  include_context "configurer integration with stubs recalled"

  def configurer
    HttpStub::Examples::ConfigurerWithStubTriggers
  end

  context "when a stub is submitted that contains triggers" do

    context "that trigger scenarios" do

      let(:triggered_scenario_names) do
        (1..3).map do |scenario_number|
          "Triggered Scenario #{scenario_number}".tap do |scenario_name|
            stub_server.add_scenario_with_one_stub!(scenario_name) do |stub|
              stub.match_requests(uri: "/triggered_scenario_#{scenario_number}", method: :get)
              stub.respond_with(status: 200 + scenario_number, body: "Triggered scenario body #{scenario_number}")
            end
          end
        end
      end

      before(:example) do
        stub_server.add_stub! do |stub|
          stub.match_requests(uri: "/triggers_scenarios", method: :get)
          stub.respond_with(body: "Stub triggering scenarios body")
          stub.trigger(scenarios: triggered_scenario_names)
        end
      end

      context "and a request is made matching the stub" do

        before(:example) { @stub_with_triggers_response = HTTParty.get("#{server_uri}/triggers_scenarios") }

        it "replays the stubbed response" do
          expect(@stub_with_triggers_response.code).to eql(200)
          expect(@stub_with_triggers_response.body).to eql("Stub triggering scenarios body")
        end

        (1..3).each do |scenario_number|

          context "and then a request matching triggered scenario ##{scenario_number} is made" do

            let(:response) { HTTParty.get("#{server_uri}/triggered_scenario_#{scenario_number}") }

            it "replays the triggered response" do
              expect(response.code).to eql("20#{scenario_number}".to_i)
              expect(response.body).to eql("Triggered scenario body #{scenario_number}")
            end

          end

        end

      end

    end

    context "that trigger stubs" do

      let(:triggered_stubs) do
        (1..3).map do |trigger_number|
          stub_server.build_stub do |stub|
            stub.match_requests(uri: "/triggered_stub_#{trigger_number}", method: :get)
            stub.respond_with(status: 200 + trigger_number, body: "Triggered stub body #{trigger_number}")
          end
        end
      end

      before(:example) do
        stub_server.add_stub! do |stub|
          stub.match_requests(uri: "/triggers_stubs", method: :get)
          stub.respond_with(body: "Stub triggering stubs body")
          stub.trigger(stubs: triggered_stubs)
        end
      end

      context "and a request is made matching the stub" do

        before(:example) { @stub_with_triggers_response = HTTParty.get("#{server_uri}/triggers_stubs") }

        it "replays the stubbed response" do
          expect(@stub_with_triggers_response.code).to eql(200)
          expect(@stub_with_triggers_response.body).to eql("Stub triggering stubs body")
        end

        (1..3).each do |trigger_number|

          context "and then a request matching a triggered stub ##{trigger_number} is made" do

            let(:response) { HTTParty.get("#{server_uri}/triggered_stub_#{trigger_number}") }

            it "replays the triggered response" do
              expect(response.code).to eql("20#{trigger_number}".to_i)
              expect(response.body).to eql("Triggered stub body #{trigger_number}")
            end

          end

        end

      end

    end

    context "that contain a mix of text and file responses" do

      let(:pdf_file_path) { "#{HttpStub::Spec::RESOURCES_DIR}/sample.pdf" }
      let(:pdf_file_trigger) do
        stub_server.build_stub do |stub|
          stub.match_requests(uri: "/triggered_stub_pdf_file", method: :get)
          stub.respond_with(
            headers: { "content-type" => "application/pdf" },
            body:    { file: { path: pdf_file_path, name: ::File.basename(pdf_file_path) } }
          )
        end
      end

      let(:text_body) { "Sample trigger stub body" }
      let(:text_trigger) do
        stub_server.build_stub do |stub|
          stub.match_requests(uri: "/triggered_stub_text", method: :get)
          stub.respond_with(status: 201, body: "Sample trigger stub body")
        end
      end

      let(:txt_file_path) { "#{HttpStub::Spec::RESOURCES_DIR}/sample.txt" }
      let(:txt_file_trigger) do
        stub_server.build_stub do |stub|
          stub.match_requests(uri: "/triggered_stub_txt_file", method: :get)
          stub.respond_with(
            headers: { "content-type" => "text/plain" },
            body:    { file: { path: txt_file_path, name: ::File.basename(txt_file_path) } }
          )
        end
      end

      let(:triggered_stubs) { [ pdf_file_trigger, text_trigger, txt_file_trigger ] }

      before(:example) do
        stub_server.add_stub! do |stub|
          stub.match_requests(uri: "/stub_with_triggers", method: :get)
          stub.respond_with(body: "Trigger stub body")
          stub.trigger(stubs: triggered_stubs)
        end
      end

      context "and a request is made matching the stub" do

        before(:example) { HTTParty.get("#{server_uri}/stub_with_triggers") }

        context "and then a request matching a triggered stub returning a PDF file is made" do

          let(:response) { HTTParty.get("#{server_uri}/triggered_stub_pdf_file") }

          it "replays the triggered response" do
            expect(response.code).to eql(200)
            expect(response).to contain_file(pdf_file_path)
          end

        end

        context "and then a request matching a triggered stub returning texrt is made" do

          let(:response) { HTTParty.get("#{server_uri}/triggered_stub_text") }

          it "replays the triggered response" do
            expect(response.code).to eql(201)
            expect(response.body).to eql(text_body)
          end

        end

        context "and then a request matching a triggered stub returning a text file is made" do

          let(:response) { HTTParty.get("#{server_uri}/triggered_stub_txt_file") }

          it "replays the triggered response" do
            expect(response.code).to eql(200)
            expect(response.parsed_response).to eql(::File.read(txt_file_path))
          end

        end

      end

    end

  end

end
