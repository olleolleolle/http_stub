describe HttpStub::Server::Application::Routes::Status do
  include_context "http_stub rack application test"

  context "when a request to show the servers current status is received" do

    subject { get "/http_stub/status" }

    it "responds with a body indicating the server is running" do
      subject

      expect(response.body).to eql("OK")
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

end
