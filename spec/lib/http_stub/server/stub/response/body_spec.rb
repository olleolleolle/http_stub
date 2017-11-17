describe HttpStub::Server::Stub::Response::Body do

  describe "::create" do

    subject { described_class.create(args) }

    context "when a body argument containing text is provided" do

      let(:args) { HttpStub::Server::Stub::Response::TextBodyFixture.args_with_body }

      it "returns a text body" do
        expect(subject).to be_an_instance_of(HttpStub::Server::Stub::Response::TextBody)
      end

      it "has text which is the value of the body" do
        expect(subject.text).to eql(args[:body])
      end

    end

    context "when a json argument is provided" do

      let(:args) { HttpStub::Server::Stub::Response::TextBodyFixture.args_with_json }

      it "returns a text body" do
        expect(subject).to be_an_instance_of(HttpStub::Server::Stub::Response::TextBody)
      end

      it "has text which is the JSON representation of the value" do
        expect(subject.text).to eql(args[:json].to_json)
      end

    end

    context "when a body argument containing a file is provided" do

      let(:args)      { { body: HttpStub::Server::Stub::Response::FileBodyFixture.args } }
      let(:file_path) { args[:body][:file][:path] }

      it "returns a file body" do
        expect(subject).to be_an_instance_of(HttpStub::Server::Stub::Response::FileBody)
      end

      it "has a uri which includes the path to the file" do
        expect(subject.uri).to include(file_path)
      end

    end

  end

end
