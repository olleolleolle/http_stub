describe HttpStub::Server::Application::ResponseSupport do

  context "when included in an application" do
    include_context "rack application test"

    class HttpStub::Server::Application::ResponseSupportTestApplication < Sinatra::Base

      include HttpStub::Server::Application::ResponseSupport

      get "/response_support_test" do
        halt 200
      end

    end

    let(:app_class) { HttpStub::Server::Application::ResponseSupportTestApplication }

    it "creates a response pipeline for the application when handling a request" do
      expect(HttpStub::Server::Application::ResponsePipeline).to receive(:new).with(an_instance_of(app_class))

      issue_a_request
    end

    def issue_a_request
      get "/response_support_test"
    end

  end

end
