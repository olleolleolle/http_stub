describe HttpStub::Server::Application::ResponsePipeline do

  let(:application) { instance_double(Sinatra::Base) }

  let(:response_pipeline) { described_class.new(application) }

  describe "#process" do

    let(:response) { double(HttpStub::Server::Stub::Response::Base, delay_in_seconds: 5, serve_on: nil) }

    before(:example) { allow(response_pipeline).to receive(:sleep) }

    subject { response_pipeline.process(response) }

    it "sleeps for the duration declared in the response" do
      expect(response_pipeline).to receive(:sleep).with(5)

      subject
    end

    it "serves the response via the application" do
      expect(response).to receive(:serve_on).with(application)

      subject
    end

  end

end
