describe HttpStub::Server::Application::Routes::Session do
  include_context "http_stub rack application test"

  let(:session_controller) { instance_double(HttpStub::Server::Session::Controller) }

  before(:example) { allow(HttpStub::Server::Session::Controller).to receive(:new).and_return(session_controller) }

  context "when a request to show the administration landing page is received" do

    subject { get "/http_stub" }

    context "and session support is enabled" do

      include_context "enabled session support"

      let(:found_sessions) { [ HttpStub::Server::SessionFixture.create(request) ] }

      before(:example) { allow(session_controller).to receive(:find_all).and_return(found_sessions) }

      it "responds with a redirect" do
        subject

        expect(response.status).to eql(302)
      end

      it "redirects to the page listing all session" do
        subject

        expect(response.location).to end_with("/http_stub/sessions")
      end

    end

    context "and session support is disabled" do

      it "responds with a redirect" do
        subject

        expect(response.status).to eql(302)
      end

      it "redirects to the default session page" do
        subject

        expect(response.location).to end_with("/http_stub/sessions/#{HttpStub::Server::Session::DEFAULT_ID}")
      end

    end

  end

  context "when a request to list the sessions is received" do

    let(:found_sessions) { [ HttpStub::Server::SessionFixture.create(request) ] }

    subject { get "/http_stub/sessions" }

    before(:example) { allow(session_controller).to receive(:find_all).and_return(found_sessions) }

    it "retrieves all sessions via the session controller" do
      expect(session_controller).to receive(:find_all).and_return(found_sessions)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  context "when a request to show a session is received" do

    let(:session_id)    { SecureRandom.uuid }
    let(:found_session) { HttpStub::Server::SessionFixture.create(request) }

    subject { get "/http_stub/sessions/#{session_id}" }

    before(:example) { allow(session_controller).to receive(:find).and_return(found_session) }

    it "retrieves the session via the stub controller" do
      expect(session_controller).to receive(:find).with(request, anything).and_return(found_session)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

end
