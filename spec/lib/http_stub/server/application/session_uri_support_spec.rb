describe HttpStub::Server::Application::SessionUriSupport do

  class HttpStub::Server::Application::SessionUriSupport::TestApplication
    include HttpStub::Server::Application::SessionUriSupport

    def initialize(request)
      @request = request
    end

    def http_stub_request
      @request
    end

  end

  let(:session_id) { "some_session_id" }
  let(:session)    { instance_double(HttpStub::Server::Session::Session, id: session_id) }
  let(:request)    { instance_double(HttpStub::Server::Request::Request, session: session) }

  let(:application) { HttpStub::Server::Application::SessionUriSupport::TestApplication.new(request) }

  describe "#session_uri" do

    let(:uri) { "http://some/uri" }

    subject { application.session_uri(uri) }

    context "when the uri contains parameters" do

      let(:uri) { "http://some/uri?parameter_name=parameter_value" }

      it "adds a http_stub_session_id parameter to the uri containing the current session id" do
        expect(subject).to eql("#{uri}&http_stub_session_id=some_session_id")
      end

    end

    context "when the uri does not contain parameters" do

      it "adds a http_stub_session_id parameter to the uri containing the current session id" do
        expect(subject).to eql("#{uri}?http_stub_session_id=some_session_id")
      end

    end

  end

end
