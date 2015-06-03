describe "Stub trigger acceptance" do
  include_context "configurer integration"

  let(:configurer) { HttpStub::Examples::ConfigurerWithTriggers.new }

  before(:example) { configurer.class.initialize! }

  context "when a stub is submitted that contains triggers" do

    context "with simple response bodies" do

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

    context "with a mix of text and file responses" do

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

end
