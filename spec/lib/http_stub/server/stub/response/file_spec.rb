describe HttpStub::Server::Stub::Response::File do

  let(:headers)         { {} }
  let(:file_name)       { "sample.txt" }
  let(:temp_file_path)  { "#{HttpStub::Spec::RESOURCES_DIR}/#{file_name}" }
  let(:body)            { { filename: file_name, tempfile: File.new(temp_file_path) } }
  let(:additional_args) { {} }
  let(:args)            { { "headers" => headers, "body" => body }.merge(additional_args) }

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

  describe "#with_values_from" do

    let(:request)              { instance_double(HttpStub::Server::Request::Request) }
    let(:interpolated_headers) { { interpolated_header_name: "some interpolated header value" } }
    let(:response_headers)     do
      instance_double(HttpStub::Server::Stub::Response::Attribute::Headers, with_values_from: interpolated_headers)
    end

    subject { response_file.with_values_from(request) }

    before(:example) do
      allow(HttpStub::Server::Stub::Response::Attribute::Headers).to receive(:new).and_return(response_headers)
      ensure_response_file_is_created!
    end

    it "interpolates headers with values from the request" do
      expect(response_headers).to receive(:with_values_from).with(request)

      subject
    end

    it "creates a new response file with the interpolated headers" do
      expect(described_class).to receive(:new).with(hash_including("headers" => interpolated_headers))

      subject
    end

    it "creates a new response file with other arguments preserved" do
      expect(described_class).to receive(:new).with(hash_including("body" => body))

      subject
    end

    it "returns the created file response" do
      new_file_response = instance_double(described_class)
      expect(described_class).to receive(:new).and_return(new_file_response)

      expect(subject).to eql(new_file_response)
    end

    def ensure_response_file_is_created!
      response_file
    end

  end

  describe "#serve_on" do

    let(:status)          { 321 }
    let(:additional_args) { { "status" => status } }
    let(:server)          { instance_double(Sinatra::Base) }

    subject { response_file.serve_on(server) }

    it "sends the temp file via the server" do
      expect(server).to receive(:send_file).with(temp_file_path, anything)

      subject
    end

    it "sends the file without any provided response status to ensure that 304 responses are honoured" do
      expect(server).to receive(:send_file).with(anything, hash_excluding(:status))

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
