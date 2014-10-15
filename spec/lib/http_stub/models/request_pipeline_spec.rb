describe HttpStub::Models::RequestPipeline do

  let(:request_pipeline) { HttpStub::Models::RequestPipeline }

  describe ".before_halt" do

    let(:response) { double(HttpStub::Models::Response, delay_in_seconds: 5) }

    it "sleeps for specified duration" do
      expect(request_pipeline).to receive(:sleep).with(5)

      request_pipeline.before_halt(response)
    end

  end

end
