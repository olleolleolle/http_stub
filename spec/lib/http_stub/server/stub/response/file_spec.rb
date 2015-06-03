describe HttpStub::Server::Stub::Response::File do

  let(:status)         { 321 }
  let(:headers)        { {} }
  let(:file_name)      { "sample.txt" }
  let(:temp_file_path) { "#{HttpStub::Spec::RESOURCES_DIR}/#{file_name}" }
  let(:args) do
    {
      "status" => status,
      "headers" => headers,
      "body" => { filename: file_name, tempfile: File.new(temp_file_path) }
    }
  end

  let(:response_file) { HttpStub::Server::Stub::Response::File.new(args) }

  it "is a base response" do
    expect(response_file).to be_a(HttpStub::Server::Stub::Response::Base)
  end

  describe "#uri" do

    subject { response_file.uri }

    it "is prefixed with 'file://' to support display within a hyperlink" do
      expect(subject).to start_with("file://")
    end

    it "concludes with the path to the temp file provided" do
      expect(subject).to end_with(temp_file_path)
    end

  end

  describe "#serve_on" do

    let(:server) { instance_double(Sinatra::Base) }

    subject { response_file.serve_on(server) }

    it "sends the temp file via the server" do
      expect(server).to receive(:send_file).with(temp_file_path, anything)

      subject
    end

    it "sends the file with the responses status" do
      expect(server).to receive(:send_file).with(anything, hash_including(status: status))

      subject
    end

    context "when a content type header is specified" do

      let(:content_type) { "plain/text" }
      let(:headers)      { { "content-type" => content_type } }

      it "sends the file with a type that is the provided content type" do
        expect(server).to receive(:send_file).with(anything, hash_including(type: content_type))

        subject
      end

    end

    context "when no content type header is specified" do

      let(:headers) { {} }

      it "sends the file with a type of application/octet-stream" do
        expect(server).to receive(:send_file).with(anything, hash_including(type: "application/octet-stream"))

        subject
      end

    end

    context "when a last modified header is specified" do

      let(:last_modified_date) { "Thu, 14 May 2015 12:56:00 GMT" }
      let(:headers)            { { "last-modified" => last_modified_date } }

      it "sends the file with the last modified date" do
        expect(server).to receive(:send_file).with(anything, hash_including(last_modified: last_modified_date))

        subject
      end

    end

    context "when no last modified header is specified" do

      let(:headers) { {} }

      it "sends the file without a last modified date" do
        expect(server).to receive(:send_file).with(anything, hash_excluding(:last_modified))

        subject
      end

    end

    context "when a content disposition header is specified" do

      let(:content_disposition) { "attachment" }
      let(:headers)             { { "content-disposition" => content_disposition } }

      it "sends the file with a disposition whose value is the provided content disposition" do
        expect(server).to receive(:send_file).with(anything, hash_including(disposition: content_disposition))

        subject
      end

    end

    context "when a content disposition header is not specified" do

      let(:headers) { {} }

      it "sends the file without a disposition" do
        expect(server).to receive(:send_file).with(anything, hash_excluding(:disposition))

        subject
      end

    end

  end

end
