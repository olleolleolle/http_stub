describe HttpStub::Server::Stub::Response::FileBody do

  let(:args)      { HttpStub::Server::Stub::Response::FileBodyFixture.args }
  let(:file_path) { args[:file][:path] }

  let(:file_body) { described_class.new(args) }

  describe "#headers" do

    subject { file_body.headers }

    it "includes a content-type of application/octet-stream" do
      expect(subject).to include("content-type" => "application/octet-stream")
    end

  end

  describe "#uri" do

    subject { file_body.uri }

    it "returns the url to the file navigable by a browser" do
      expect(subject).to eql("file://#{file_path}")
    end

  end

  describe "#serve" do

    let(:content_type) { "plain/text" }
    let(:headers)      { { "content-type" => content_type } }
    let(:response)     { HttpStub::Server::Stub::ResponseBuilder.new.with_headers!(headers).build }
    let(:application)  { instance_double(Sinatra::Base) }

    subject { file_body.serve(application, response) }

    it "sends the file via the application" do
      expect(application).to receive(:send_file).with(file_path, anything)

      subject
    end

    it "sends the file without any provided response status to ensure that 304 responses are honoured" do
      expect(application).to receive(:send_file).with(anything, hash_excluding(:status))

      subject
    end

    it "sends the file with a type that is the configured content type" do
      expect(application).to receive(:send_file).with(anything, hash_including(type: content_type))

      subject
    end

    context "when a last modified header is configured in the stub response" do

      let(:last_modified_date) { "Thu, 14 May 2015 12:56:00 GMT" }
      let(:headers)            { { "last-modified" => last_modified_date } }

      it "sends the file with the last modified date" do
        expect(application).to receive(:send_file).with(anything, hash_including(last_modified: last_modified_date))

        subject
      end

    end

    context "when no last modified header is configured in the stub response" do

      let(:headers) { {} }

      it "sends the file without a last modified date" do
        expect(application).to receive(:send_file).with(anything, hash_excluding(:last_modified))

        subject
      end

    end

    context "when a content disposition header is configured in the stub response" do

      let(:content_disposition) { "attachment" }
      let(:headers)             { { "content-disposition" => content_disposition } }

      it "sends the file with a disposition whose value is the configured content disposition" do
        expect(application).to receive(:send_file).with(anything, hash_including(disposition: content_disposition))

        subject
      end

    end

    context "when a content disposition header is not configured in the stub response" do

      let(:headers) { {} }

      it "sends the file without a disposition" do
        expect(application).to receive(:send_file).with(anything, hash_excluding(:disposition))

        subject
      end

    end

  end

  describe "#to_s" do

    subject { file_body.to_s }

    it "returns the uri" do
      expect(subject).to eql(file_body.uri)
    end

  end

end
