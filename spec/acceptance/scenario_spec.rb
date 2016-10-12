describe "Scenario acceptance" do

  context "when a configurer that contains scenarios is initialized" do
    include_context "configurer integration"

    let(:configurer_specification) { { class: HttpStub::Examples::ConfigurerWithTrivialScenarios } }

    context "and a scenario is activated" do

      context "containing stubs" do

        before(:example) { stub_server.activate!("Scenario 1") }

        (1..3).each do |stub_number|

          context "and scenario stub request ##{stub_number} is made" do

            let(:response) { HTTParty.get("#{server_uri}/scenario_stub_path_#{stub_number}") }

            it "replays the stubbed response" do
              expect(response.code).to eql(200 + stub_number)
              expect(response.body).to eql("Scenario stub #{stub_number} body")
            end

          end

        end

      end

      context "containing triggered scenarios" do

        before(:example) { stub_server.activate!("Activates another scenario") }

        (1..3).each do |stub_number|

          context "and a request is made matching stub ##{stub_number} within the triggered scenario" do

            let(:response) { HTTParty.get("#{server_uri}/scenario_stub_path_#{stub_number}") }

            it "triggers all related scenarios" do
              expect(response.code).to eql(200 + stub_number)
              expect(response.body).to eql("Scenario stub #{stub_number} body")
            end

          end

        end

      end

    end

    context "and the scenario is not activated" do

      context "and a scenario stub request is made" do

        let(:response) { HTTParty.get("#{server_uri}/scenario_stub_path_1") }

        it "responds with a 404 status code" do
          expect(response.code).to eql(404)
        end

      end

    end

    context "and the response contains a file" do

      let(:configurer_specification) { { class: HttpStub::Examples::ConfigurerWithFileResponses } }

      before(:example) { stub_server.activate!("Scenario with file") }

      context "and the stub request is made" do

        let(:response) { HTTParty.get("#{server_uri}/activated_response_with_file") }

        it "replays the stubbed response" do
          expect(response.code).to eql(200)
          expect(response).to contain_file(HttpStub::Examples::ConfigurerWithFileResponses::FILE_PATH)
        end

      end

    end

  end

end
