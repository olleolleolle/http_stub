describe HttpStub::Server::Stub::Response::Text do

  let(:status)  { 123 }
  let(:headers) { {} }
  let(:body)    { "Some text body" }
  let(:args)    { { "status" => status, "headers" => headers, "body" => body } }

  let(:response_text) { HttpStub::Server::Stub::Response::Text.new(args) }

  describe "#body" do

    it "returns the value provided in the arguments" do
      expect(response_text.body).to eql("Some text body")
    end

  end

  it "is a base response" do
    expect(response_text).to be_a(HttpStub::Server::Stub::Response::Base)
  end

  describe "#with_values_from" do

    let(:request)              { instance_double(HttpStub::Server::Request::Request) }
    let(:interpolated_headers) { { interpolated_header_name: "some interpolated header value" } }
    let(:response_headers)     do
      instance_double(HttpStub::Server::Stub::Response::Attribute::Headers, with_values_from: interpolated_headers)
    end
    let(:interpolated_body)    { "some interpolated body" }
    let(:response_body)        do
      instance_double(HttpStub::Server::Stub::Response::Attribute::Body, with_values_from: interpolated_body )
    end

    subject { response_text.with_values_from(request) }

    before(:example) do
      allow(HttpStub::Server::Stub::Response::Attribute::Headers).to receive(:new).and_return(response_headers)
      allow(HttpStub::Server::Stub::Response::Attribute::Body).to receive(:new).and_return(response_body)
      ensure_response_text_is_created!
    end

    it "interpolates headers with values from the request" do
      expect(response_headers).to receive(:with_values_from).with(request)

      subject
    end

    it "creates a new response text with the interpolated headers" do
      expect(described_class).to receive(:new).with(hash_including("headers" => interpolated_headers))

      subject
    end

    it "creates a new response text with the interpolated body" do
      expect(described_class).to receive(:new).with(hash_including("body" => interpolated_body))

      subject
    end

    it "creates a new response text with other arguments preserved" do
      expect(described_class).to receive(:new).with(hash_including("status" => status))

      subject
    end

    it "returns the created text response" do
      new_text_response = instance_double(described_class)
      expect(described_class).to receive(:new).and_return(new_text_response)

      expect(subject).to eql(new_text_response)
    end

    def ensure_response_text_is_created!
      response_text
    end

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

  describe "#to_hash" do

    subject { response_text.to_hash }

    describe "supporting creating a JSON representation of the response" do

      it "contains the responses body" do
        expect(subject).to include(body: response_text.body)
      end

      it "contains the standard response attributes" do
        expect(subject).to include(headers: response_text.headers)
      end

    end

  end

end
