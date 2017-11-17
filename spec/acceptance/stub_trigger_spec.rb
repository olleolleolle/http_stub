describe "Stub trigger acceptance" do
  include_context "server integration"

  let(:configurator) { HttpStub::Examples::ConfiguratorWithStubTriggers }

  context "when a stub has triggers" do

    context "that trigger scenarios" do

      context "and a request is made matching the stub" do

        before(:example) { @stub_with_triggers_response = HTTParty.get("#{server_uri}/triggers_scenarios") }

        it "replays the stubbed response" do
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
      
      context "and a request is made matching the stub" do

        before(:example) { @stub_with_triggers_response = HTTParty.get("#{server_uri}/triggers_stubs") }

        it "replays the stubbed response" do
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

    context "that contains a mix of text and file responses" do

      context "and a request is made matching the stub" do

        before(:example) { HTTParty.get("#{server_uri}/stub_with_mixed_response_triggers") }

        context "and then a request matching a triggered stub returning a PDF file is made" do

          let(:pdf_file_path) { HttpStub::Examples::ConfiguratorWithStubTriggers::PDF_FILE_PATH }

          let(:response) { HTTParty.get("#{server_uri}/triggered_stub_pdf_file") }

          it "replays the triggered response" do
            expect(response).to contain_file(pdf_file_path)
          end

        end

        context "and then a request matching a triggered stub returning text is made" do

          let(:response) { HTTParty.get("#{server_uri}/triggered_stub_text") }

          it "replays the triggered response" do
            expect(response.body).to eql("Sample trigger stub body")
          end

        end

        context "and then a request matching a triggered stub returning a text file is made" do

          let(:txt_file_path) { HttpStub::Examples::ConfiguratorWithStubTriggers::TXT_FILE_PATH }

          let(:response) { HTTParty.get("#{server_uri}/triggered_stub_txt_file") }

          it "replays the triggered response" do
            expect(response.parsed_response).to eql(::File.read(txt_file_path))
          end

        end

      end

    end

  end

end
