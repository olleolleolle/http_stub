describe HttpStub::Server::ResponsePipeline do

  let(:server)            { instance_double(HttpStub::Server) }

  let(:response_pipeline) { HttpStub::Server::ResponsePipeline.new(server) }

  describe "#process" do

    let(:response) { double(HttpStub::Server::StubResponse::Base, delay_in_seconds: 5, serve_on: nil) }

    before(:example) { allow(response_pipeline).to receive(:sleep) }

    subject { response_pipeline.process(response) }

    it "sleeps for the duration declared in the response" do
      expect(response_pipeline).to receive(:sleep).with(5)

      subject
    end

    it "serves the response via the server" do
      expect(response).to receive(:serve_on).with(server)

      subject
    end

  end

end
