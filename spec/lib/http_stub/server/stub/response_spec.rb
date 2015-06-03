describe HttpStub::Server::Stub::Response do

  describe "::create" do

    let(:response_args) { { "body" => body } }

    subject { HttpStub::Server::Stub::Response.create(response_args) }

    context "when the body contains text" do

      let(:body) { "some text" }

      it "creates a text response" do
        expect(HttpStub::Server::Stub::Response::Text).to receive(:new).with(response_args)

        subject
      end

      it "returns the created response" do
        response = instance_double(HttpStub::Server::Stub::Response::Text)
        allow(HttpStub::Server::Stub::Response::Text).to receive(:new).and_return(response)

        expect(subject).to eql(response)
      end

    end

    context "when the body contains a file" do

      let(:body) { { "file" => { "path" => "a/file.path", "name" => "a_file.name" } } }

      it "creates a file response" do
        expect(HttpStub::Server::Stub::Response::File).to receive(:new).with(response_args)

        subject
      end

      it "returns the created response" do
        response = instance_double(HttpStub::Server::Stub::Response::File)
        allow(HttpStub::Server::Stub::Response::File).to receive(:new).and_return(response)

        expect(subject).to eql(response)
      end

    end

  end

end
