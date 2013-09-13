describe HttpStub::Models::RequestPipeline do

  describe '#before_halt' do

    let(:options) {{:duration => 5}}
    let(:request_pipeline) { HttpStub::Models::RequestPipeline.new }

    before(:each) do
      request_pipeline.stub!(:sleep)
    end

    it 'should sleep for specified duration' do
      request_pipeline.should_receive(:sleep).with(options[:duration])
      request_pipeline.before_halt options
    end

    it 'should skip sleep if not specified' do
      request_pipeline.should_not_receive(:sleep)
      request_pipeline.before_halt
    end

    it 'should skip sleep if duration is negative' do
      request_pipeline.should_not_receive(:sleep)
      request_pipeline.before_halt({:duration => -1})
    end
  end
end