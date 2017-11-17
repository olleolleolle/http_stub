describe HttpStub::Client::Request do

  let(:request_method) { :post }
  let(:request_intent) { "some intent" }
  let(:request_args)            do
    {
      method:       request_method,
      base_uri:     "http://some/base/uri",
      path:         "some/path",
      intent:       request_intent
    }
  end

  let(:request) { described_class.new(request_args) }

  describe "#submit" do

    subject { request.submit }

    context "when an invalid method is provided" do

      let(:request_method) { :invalid }

      it "raises an error describing the intent of the request"  do
        expect { subject }.to raise_error(/#{request_intent}/)
      end

    end

  end

end
