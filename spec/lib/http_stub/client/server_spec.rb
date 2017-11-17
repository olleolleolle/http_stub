describe HttpStub::Client::Server do

  let(:base_uri) { "http://some/base/uri" }

  let(:server) { described_class.new(base_uri) }

  describe "::submit!" do

    let(:response_code)    { "200" }
    let(:response_message) { "some response message" }
    let(:response)         { instance_double(Net::HTTPResponse, code: response_code, message: response_message) }

    let(:request_args)                 { { key: "some value" } }
    let(:request_error_message_prefix) { "some error message prefix" }
    let(:request)                      do
      instance_double(HttpStub::Client::Request, submit: response, error_message_prefix: request_error_message_prefix)
    end

    subject { server.submit!(request_args) }

    before(:example) { allow(HttpStub::Client::Request).to receive(:new).and_return(request) }

    it "creates a request with the servers base uri" do
      expect(HttpStub::Client::Request).to receive(:new).with(hash_including(base_uri: base_uri))

      subject
    end

    it "creates a request with the provided arguments" do
      expect(HttpStub::Client::Request).to receive(:new).with(hash_including(request_args))

      subject
    end

    it "submits the request" do
      expect(request).to receive(:submit)

      subject
    end

    describe "and the responses code is 200" do

      let(:response_code) { "200" }

      it "executes without error" do
        expect { subject }.not_to raise_error
      end

      it "returns the server response" do
        expect(subject).to eql(response)
      end

    end

    describe "and the responses code is non-200" do

      let(:response_code) { "400" }

      it "raises an exception that describes the request" do
        expect { subject }.to raise_error(/#{request_error_message_prefix}/)
      end

      it "raises an exception that contains the response code" do
        expect { subject }.to raise_error(/#{response_code}/)
      end

      it "raises an exception that contains the responses message" do
        expect { subject }.to raise_error(/#{response_message}/)
      end

    end

  end

end
