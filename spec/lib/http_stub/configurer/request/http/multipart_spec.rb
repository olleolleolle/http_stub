describe HttpStub::Configurer::Request::Http::Multipart do

  let(:path)              { "/a/request/path" }
  let(:payload)           { { key: "value" } }
  let(:response_files)    { [] }
  let(:model) { instance_double(HttpStub::Configurer::Request::Stub, payload: payload, response_files: response_files) }
  let(:multipart_request) { HttpStub::Configurer::Request::Http::Multipart.new(path, model) }

  describe "#to_http_request" do

    subject { multipart_request.to_http_request }

    it "creates a HTTP multipart request" do
      expect(Net::HTTP::Post::Multipart).to receive(:new)

      subject
    end

    it "returns the created HTTP multipart request" do
      http_multipart_request = instance_double(Net::HTTP::Post::Multipart)
      allow(Net::HTTP::Post::Multipart).to receive(:new).and_return(http_multipart_request)

      expect(subject).to eql(http_multipart_request)
    end

    it "creates a HTTP request with the provided path" do
      expect(Net::HTTP::Post::Multipart).to receive(:new).with(path, anything)

      subject
    end

    it "creates a HTTP request with a payload parameter containing the JSON representation of the payload" do
      expect(Net::HTTP::Post::Multipart).to receive(:new).with(anything, hash_including(payload: payload.to_json))

      subject
    end

    context "when the payload contains response files" do

      let(:response_files) do
        (1..3).map do |i|
          instance_double(HttpStub::Configurer::Request::StubResponseFile,
                          id: "id#{i}", path: "file/path/#{i}", type: "file-type-#{i}", name: "file_name_#{i}")
        end
      end

      it "creates a HTTP request with an upload parameter for each file keyed on the file ID" do
        expected_upload_parameters = response_files.reduce({}) do |result, response_file|
          upload_file = instance_double(UploadIO)
          expect(UploadIO).to(
            receive(:new).with(response_file.path, response_file.type, response_file.name).and_return(upload_file)
          )
          result.tap { |hash| hash["response_file_#{response_file.id}"] = upload_file }
        end
        expect(Net::HTTP::Post::Multipart).to receive(:new).with(anything, hash_including(expected_upload_parameters))

        subject
      end

    end

    context "when the payload contains no response files" do

      it "creates a HTTP request with no upload parameters" do
        expect(Net::HTTP::Post::Multipart).to receive(:new).with(anything, payload: payload.to_json)

        subject
      end

    end

  end

end
