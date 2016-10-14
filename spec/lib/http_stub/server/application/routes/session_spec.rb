describe HttpStub::Server::Application::Routes::Session do
  include_context "http_stub rack application test"

  let(:session_controller) { instance_double(HttpStub::Server::Session::Controller) }

  before(:example) { allow(HttpStub::Server::Session::Controller).to receive(:new).and_return(session_controller) }

  describe "when a request to show the administration landing page is received" do

    subject { get "/http_stub" }

    context "and session support is enabled" do

      include_context "enabled session support"

      let(:found_sessions) { [ HttpStub::Server::SessionFixture.create ] }

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

      it "redirects to the transactional session page" do
        subject

        expect(response.location).to end_with("/http_stub/sessions/transactional")
      end

    end

  end

  describe "when a request to list the sessions is received" do
    include_context "request excludes a session identifier"

    let(:found_sessions) { [ HttpStub::Server::SessionFixture.create ] }

    subject { get "/http_stub/sessions" }

    before(:example) do
      allow(request).to receive(:session_id).and_return(nil)
      allow(session_controller).to receive(:find_all).and_return(found_sessions)
    end

    it "retrieves all sessions via the session controller" do
      expect(session_controller).to receive(:find_all).and_return(found_sessions)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  describe "when a request to show a session is received" do
    include_context "request includes a session identifier"

    let(:found_session) { HttpStub::Server::SessionFixture.create }

    subject { get "/http_stub/sessions" }

    before(:example) { allow(session_controller).to receive(:find).and_return(found_session) }

    it "retrieves the session identified in the request via the stub controller" do
      expect(session_controller).to receive(:find).with(request, anything).and_return(found_session)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  describe "when a request to show the transactional session is received" do

    let(:transactional_session) { HttpStub::Server::SessionFixture.create }

    subject { get "/http_stub/sessions/transactional" }

    before(:example) { allow(session_controller).to receive(:find_transactional).and_return(transactional_session) }

    it "retrieves the transactional session via the stub controller" do
      expect(session_controller).to receive(:find_transactional).with(anything).and_return(transactional_session)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  describe "when a request to mark a session as the default is received" do
    include_context "request includes a session identifier"

    subject { post "/http_stub/sessions/default" }

    before(:example) { allow(session_controller).to receive(:mark_default) }

    it "retrieves the session identified in the request via the stub controller" do
      expect(session_controller).to receive(:mark_default).with(request)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  describe "when a request to delete a session is received" do
    include_context "request includes a session identifier"

    subject { delete "/http_stub/sessions" }

    before(:example) { allow(session_controller).to receive(:delete) }

    it "deletes the session identified in the request via the stub controller" do
      expect(session_controller).to receive(:delete).with(request, anything)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  describe "when a request to clear the sessions is received" do
    include_context "request excludes a session identifier"

    subject { delete "/http_stub/sessions" }

    before(:example) { allow(session_controller).to receive(:clear) }

    it "clears the servers sessions via the stub controller" do
      expect(session_controller).to receive(:clear).with(anything)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

end
