describe HttpStub::Server::Application::RequestSupport, "when integrated into a complete Rack application" do

  context "when included in an application" do
    include_context "rack application test"

    class HttpStub::Server::Application::RequestSupport::IntegrationTestApplication < Sinatra::Base

      set :session_identifier, nil

      def initialize
        @server_memory = HttpStub::Server::MemoryFixture.create
        super()
      end

      include HttpStub::Server::Application::RequestSupport

      get "/accesses_uri" do
        halt 200, "Request path: #{http_stub_request.uri}"
      end

      post "/with_body_and_establishes_request_multiple_times" do
        establish_http_stub_request
        halt 200, "Request body: #{http_stub_request.body}"
      end

      post "/without_body" do
        establish_http_stub_request
        halt 200
      end

      any_request_method "/any_request_method_test" do
        halt 200
      end

      def logger
        HttpStub::Server::SilentLogger
      end

    end

    let(:app_class) { HttpStub::Server::Application::RequestSupport::IntegrationTestApplication }

    describe "#http_stub_request" do

      context "when an action accesses the request" do

        it "retrieves the request attributes successfully" do
          get "/accesses_uri"

          expect(response.body).to end_with("accesses_uri")
        end

        context "and the action is a POST with a body that establishes the request multiple times" do

          it "retains any request body provided" do
            post "/with_body_and_establishes_request_multiple_times", "some body"

            expect(response.body).to end_with("some body")
          end

        end

        context "and the action is a POST without a body" do

          it "executes without error" do
            post "/without_body"

            expect(response.status).to eql(200)
          end

        end

      end

    end

    describe "#any_request_method" do

      [ :get, :post, :put, :patch, :delete, :options ].each do |request_method|

        it "handles #{request_method} requests for the provided endpoint" do
          self.send(request_method, "/any_request_method_test")

          expect(response.status).to eql(200)
        end

      end

    end

  end

end
