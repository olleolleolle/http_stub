describe HttpStub::Models::StubResponse do

  describe "::create" do

    let(:response_args) { { "body" => body } }

    subject { HttpStub::Models::StubResponse.create(response_args) }

    context "when the body contains text" do

      let(:body) { "some text" }

      it "creates a text response" do
        expect(HttpStub::Models::StubResponse::Text).to receive(:new).with(response_args)

        subject
      end

      it "returns the created response" do
        response = instance_double(HttpStub::Models::StubResponse::Text)
        allow(HttpStub::Models::StubResponse::Text).to receive(:new).and_return(response)

        expect(subject).to eql(response)
      end

    end

    context "when the body contains a file" do

      let(:body) { { "file" => { "path" => "a/file.path", "name" => "a_file.name" } } }

      it "creates a file response" do
        expect(HttpStub::Models::StubResponse::File).to receive(:new).with(response_args)

        subject
      end

      it "returns the created response" do
        response = instance_double(HttpStub::Models::StubResponse::File)
        allow(HttpStub::Models::StubResponse::File).to receive(:new).and_return(response)

        expect(subject).to eql(response)
      end

    end

  end

end
