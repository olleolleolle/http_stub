describe HttpStub::Server::Application::SessionUriSupport do

  let(:application)         { Class.new }
  let(:session_uri_support) { application.extend(described_class) }

  describe "#session_uri" do

    let(:uri)        { "http://some/uri" }
    let(:session_id) { "some_session_id" }
    let(:session)    { instance_double(HttpStub::Server::Session::Session, id: session_id) }
    let(:request)    { instance_double(HttpStub::Server::Request::Request, session: session) }

    subject { session_uri_support.session_uri(uri) }

    before(:example) { application.instance_variable_set(:@http_stub_request, request) }

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
