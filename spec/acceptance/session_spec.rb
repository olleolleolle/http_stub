describe "Session acceptance" do

  context "when a configurer that has a session identifier is initialized" do
    include_context "configurer integration with stubs recalled"

    def configurer
      HttpStub::Examples::ConfigurerWithSessions
    end

    context "when a stub is added to a session" do

      let(:stub_session_id) { "some_session" }
      let(:stub_session)    { stub_server.session(stub_session_id) }

      let(:match_response) { HTTParty.get("#{server_uri}/matching_path", request_session_id_header) }

      before(:example) do
        stub_session.activate!("Some Scenario")
        match_response
      end

      context "and a matching request is issued from the same session" do

        let(:request_session_id) { stub_session_id }

        let(:match_list_response) { HTTParty.get("#{server_uri}/http_stub/stubs/matches", request_session_id_header) }

        it "matches" do
          expect(match_response.code).to eql(200)
        end

        it "registers a match" do
          expect(match_list_response.body).to include("matching_path")
        end

      end

      context "and a matching request is issued from another session" do

        let(:request_session_id) { "another_session" }

        let(:miss_list_response) { HTTParty.get("#{server_uri}/http_stub/stubs/misses", request_session_id_header) }

        it "does not match" do
          expect(match_response.code).to eql(404)
        end

        it "registers a miss" do
          expect(miss_list_response.body).to include("matching_path")
        end

      end

    end

    def request_session_id_header
      { headers: { "http_stub_session_id" => request_session_id } }
    end

  end

end
