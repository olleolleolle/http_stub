describe HttpStub::Server::Application::RequestSupport do

  context "when included in an application" do
    include_context "rack application test"

    class HttpStub::Server::Application::RequestSupportTestApplication < Sinatra::Base

      include HttpStub::Server::Application::RequestSupport

      set :session_identifier, { headers: :some_session_identifier }

      def initialize(session_registry, scenario_registry)
        @session_registry  = session_registry
        @scenario_registry = scenario_registry
        super()
      end

      get "/request_support_test" do
        halt 200
      end

      any_request_method "/any_request_method_test" do
        halt 200
      end

    end

    let(:session_registry)  { instance_double(HttpStub::Server::Registry) }
    let(:scenario_registry) { instance_double(HttpStub::Server::Registry) }
    let(:request_factory)   { instance_double(HttpStub::Server::Request::Factory, create: nil) }

    let(:app_class) { HttpStub::Server::Application::RequestSupportTestApplication }
    let(:app)       { app_class.new!(session_registry, scenario_registry) }

    before(:example) { allow(HttpStub::Server::Request::Factory).to receive(:new).and_return(request_factory) }

    it "creates a factory for creating http_stub requests with the applications configured session identifier" do
      expect(HttpStub::Server::Request::Factory).to(
        receive(:new).with({ headers: :some_session_identifier }, anything, anything)
      )

      app
    end

    it "creates a factory for creating http_stub requests with the applications session and scenario registries" do
      expect(HttpStub::Server::Request::Factory).to receive(:new).with(anything, session_registry, scenario_registry)

      app
    end

    it "creates a http_stub request for rack requests issued" do
      expect(request_factory).to receive(:create).with(a_kind_of(Rack::Request), anything, anything)

      issue_a_request
    end

    describe "#any_request_method" do

      [ :get, :post, :put, :patch, :delete, :options ].each do |request_method|

        it "handles #{request_method} requests for the provided endpoint" do
          self.send(request_method, "/any_request_method_test")

          expect(response.status).to eql(200)
        end

      end

    end

    def issue_a_request
      get "/test"
    end

  end

end
