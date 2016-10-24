describe HttpStub::Server::Application::Routes::Status do
  include_context "http_stub rack application test"

  let(:status_controller) { instance_double(HttpStub::Server::Status::Controller) }

  before(:example) { allow(HttpStub::Server::Status::Controller).to receive(:new).and_return(status_controller) }

  context "when a request to show the servers current status is received" do

    let(:current_status) { "Some status" }

    subject { get "/http_stub/status" }

    before(:example) { allow(status_controller).to receive(:current).and_return(current_status) }

    it "retrieves the servers current status via the status controller" do
      expect(status_controller).to receive(:current).and_return("some status")

      subject
    end

    it "responds with a body containing the servers current status" do
      subject

      expect(response.body).to eql(current_status)
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  context "when a request to mark the server as initialized is received" do

    subject { post "/http_stub/status/initialized" }

    before(:example) { allow(status_controller).to receive(:initialized) }

    it "marks the server as initialized via the status controller" do
      expect(status_controller).to receive(:initialized)

      subject
    end

    it "responds without error" do
      subject

      expect(response.status).to eql(200)
    end

  end

end
