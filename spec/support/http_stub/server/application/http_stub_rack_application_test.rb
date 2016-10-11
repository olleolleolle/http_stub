shared_context "http_stub rack application test" do
  include_context "rack application test"

  let(:response)      { last_response }
  let(:response_body) { response.body.to_s }

  let(:request)         { HttpStub::Server::RequestFixture.create }
  let(:request_factory) { instance_double(HttpStub::Server::Request::Factory, create: request) }

  let(:response_pipeline) { instance_double(HttpStub::Server::Application::ResponsePipeline, process: nil) }

  let(:app_class) { HttpStub::Server::Application::Application }
  let(:app)       { app_class.new! }

  before(:example) do
    allow(HttpStub::Server::Request::Factory).to receive(:new).and_return(request_factory)
    allow(HttpStub::Server::Application::ResponsePipeline).to receive(:new).and_return(response_pipeline)
  end

  shared_context "enabled session support" do

    let(:session_identifier) { { header: :some_session_identifier } }

    before(:example) do
      @original_session_identifier = app_class.settings.session_identifier
      app_class.set :session_identifier, session_identifier
    end

    after(:example) { app_class.set :session_identifier, @original_session_identifier }

  end

  shared_context "request excludes a session identifier" do

    before(:example) { allow(request).to receive(:session_id).and_return(nil) }

  end

  shared_context "request includes a session identifier" do

    let(:session_id) { SecureRandom.uuid }

    before(:example) { allow(request).to receive(:session_id).and_return(session_id) }

  end

end
