describe "Session acceptance" do

  context "when a configurer that has a session support enabled is initialized" do
    include_context "configurer integration"

    let(:configurer_specification) do
      { class: HttpStub::Examples::ConfigurerWithSessions, name: :session_based_stub, port: 8003 }
    end

    context "when a stub is added to a session" do

      let(:stub_session_id) { "some_session" }
      let(:stub_session)    { stub_server.session(stub_session_id) }

      let(:match_response) { HTTParty.get("#{server_uri}/matching_path", request_session_id_header) }

      before(:example) { stub_session.activate!("Some Scenario") }

      context "and a matching request is made "do

        before(:example) { match_response }

        context "that is issued from the same session" do

          let(:request_session_id) { stub_session_id }

          let(:match_list_response) { HTTParty.get("#{server_uri}/http_stub/stubs/matches", request_session_id_header) }

          it "matches" do
            expect(match_response.code).to eql(200)
          end

          it "registers a match" do
            expect(match_list_response.body).to include("matching_path")
          end

        end

        context "that is issued from another session" do

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

      context "and the session is reset" do

        let(:request_session_id) { stub_session_id }

        before(:example) { stub_session.reset! }

        context "and a matching request is issued from the same session" do

          it "does not match" do
            expect(match_response.code).to eql(404)
          end

        end

      end

      def request_session_id_header
        { headers: { "http_stub_session_id" => request_session_id } }
      end

    end

    context "when many sessions have been created" do

      let(:session_ids) { (1..3).map { |i| "session#{i}"} }
      let(:sessions)    { session_ids.map { |session_id| stub_server.session(session_id) } }

      before(:example) { sessions.each { |session| session.activate!("Some Scenario") } }

      describe "the administration landing page" do

        let(:landing_page_response) { HTTParty.get("#{server_uri}/http_stub") }

        it "lists the sessions" do
          session_ids.each { |session_id| expect(landing_page_response.body).to include(session_id) }
        end

        it "does not link to stubs" do
          expect(landing_page_response.body).to_not include("/stubs")
        end

      end

    end

  end

  context "when a configurer that has a session support disabled is initialized" do
    include_context "configurer integration"

    let(:configurer_specification) { { class: HttpStub::EmptyConfigurer } }

    describe "the administration landing page" do

      let(:landing_page_response) { HTTParty.get("#{server_uri}/http_stub") }

      it "links to stubs" do
        expect(landing_page_response.body).to include("/stubs")
      end

      it "does not list sessions" do
        expect(landing_page_response.body).to_not include("/sessions")
      end

    end

  end

end
