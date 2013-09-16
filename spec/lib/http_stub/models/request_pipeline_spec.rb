describe HttpStub::Models::RequestPipeline do

  describe '.before_halt' do

    let(:response) { double(HttpStub::Models::Response) }
    let(:request_pipeline) { HttpStub::Models::RequestPipeline }

    before(:each) do
      request_pipeline.stub(:sleep)
      response.stub(:delay_in_seconds).and_return(5)
    end

    it 'should sleep for specified duration' do
      request_pipeline.should_receive(:sleep).with(5)
      request_pipeline.before_halt(response)
    end

    it 'should skip sleep if not specified' do
      request_pipeline.should_not_receive(:sleep)
      response.stub(:delay_in_seconds).and_return(nil)
      request_pipeline.before_halt(response)
    end
  end
end