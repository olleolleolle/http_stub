describe HttpStub::Server::Application::Routes::Resource do
  include_context "http_stub rack application test"

  context "when a request for the administration pages stylesheet has been received" do

    subject { get "/application.css" }

    it "responds without error" do
      subject

      expect(response.status).to eql(200)
    end

  end

end
