describe HttpStub::Server::Stub::Response::Text do

  let(:status)  { 123 }
  let(:headers) { {} }
  let(:body)    { "Some text body" }
  let(:args) { { "status" => status, "headers" => headers, "body" => body } }

  let(:response_text) { HttpStub::Server::Stub::Response::Text.new(args) }

  it "is a base response" do
    expect(response_text).to be_a(HttpStub::Server::Stub::Response::Base)
  end

  describe "#serve_on" do

    let(:server) { instance_double(Sinatra::Base) }

    subject { response_text.serve_on(server) }

    it "halts processing of the servers request" do
      expect(server).to receive(:halt)

      subject
    end

    it "halts with the responses status" do
      expect(server).to receive(:halt).with(status, anything, anything)

      subject
    end

    context "when headers are provided" do

      context "that contain a content-type" do

        let(:headers) do
          {
            "content-type"       => "some/content/type",
            "another-header"     => "some value",
            "yet-another-header" => "some other value"
          }
        end

        it "halts with the provided headers" do
          expect(server).to receive(:halt).with(anything, headers, anything)

          subject
        end

      end

      context "that do not contain a content-type" do

        let(:headers) do
          {
            "a-header"           => "some value",
            "another-header"     => "another value",
            "yet-another-header" => "yet another value"
          }
        end

        it "halts with the provided headers" do
          expect(server).to receive(:halt).with(anything, hash_including(headers), anything)

          subject
        end

        it "halts with a default content-type of application/json" do
          expect_server_to_halt_with_default_content_type

          subject
        end

      end

    end

    context "when no headers are provided" do

      let(:headers) { {} }

      it "halts with a default content-type of application/json" do
        expect_server_to_halt_with_default_content_type

        subject
      end

    end

    it "halts with the responses body" do
      expect(server).to receive(:halt).with(anything, anything, body)

      subject
    end

    def expect_server_to_halt_with_default_content_type
      expected_content_type_entry = { "content-type" => "application/json" }
      expect(server).to receive(:halt).with(anything, hash_including(expected_content_type_entry), anything)
    end

  end

end
