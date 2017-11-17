describe HttpStub::Server::Stub::Response::Response do

  let(:status)           { 202 }
  let(:body)             { "" }
  let(:headers)          { nil }
  let(:delay_in_seconds) { 18 }
  let(:blocks)           { nil }
  let(:args)             do
    { status: status, body: body, headers: headers, delay_in_seconds: delay_in_seconds, blocks: blocks }
  end

  let(:response) { described_class.new(args) }

  describe "#status" do

    subject { response.status }

    context "when a value is provided in the arguments" do

      context "that is an integer" do

        it "returns the value provided" do
          expect(subject).to eql(status)
        end

      end

    end

    context "when the status is not provided in the arguments" do

      let(:args) { {} }

      it "defaults to 200" do
        expect(subject).to eql(200)
      end

    end

  end

  describe "#body" do

    subject { response.body }

    context "when a json argument is provided" do

      let(:json) { "some json" }
      let(:args) { HttpStub::Server::Stub::Response::TextBodyFixture.args_with_json(json) }

      it "returns a text body" do
        expect(subject).to be_an_instance_of(HttpStub::Server::Stub::Response::TextBody)
      end

      it "returns a body containing the json" do
        expect(subject.to_s).to eql(json)
      end

    end

    context "when a body argument is provided" do

      let(:args) { { body: body } }

      context "that contains text" do

        let(:body) { "some text" }

        it "returns a text body" do
          expect(subject).to be_an_instance_of(HttpStub::Server::Stub::Response::TextBody)
        end

        it "returns a body containing the text" do
          expect(subject.to_s).to eql(body)
        end

      end

      context "that contains a file" do

        let(:body) { HttpStub::Server::Stub::Response::FileBodyFixture.args }

        it "returns a file body" do
          expect(subject).to be_an_instance_of(HttpStub::Server::Stub::Response::FileBody)
        end

        it "returns a body containing the path to the file" do
          expect(subject.to_s).to include(body.dig(:file, :path))
        end

      end

    end

    context "when no body arguments are provided" do

      it "returns a text body" do
        expect(subject).to be_an_instance_of(HttpStub::Server::Stub::Response::TextBody)
      end

      it "defaults to an empty body" do
        expect(response.body.to_s).to eql("")
      end

    end

  end

  describe "#headers" do

    let(:response_header_hash) { response.headers.to_hash }

    it "has a well formatted string representation" do
      expect(response.headers).to be_a(HttpStub::Server::Stub::Response::Headers)
    end

    context "when headers are provided" do

      let(:headers) do
        {
          "a_header" => "some header",
          "another_header" => "another value",
          "yet_another_header" => "yet another value"
        }
      end

      it "returns the headers" do
        expect(response_header_hash).to eql(headers)
      end

    end

    context "and no headers are provided" do

      let(:headers) { nil }

      it "returns an empty hash" do
        expect(response_header_hash).to eql({})
      end

    end

  end

  describe "#delay_in_seconds" do

    context "when a value is provided in the arguments" do

      context "that is an integer" do

        it "returns the value" do
          expect(response.delay_in_seconds).to eql(delay_in_seconds)
        end

      end

    end

    context "when a value is not provided in the arguments" do

      let(:args) { {} }

      it "defaults to 0" do
        expect(response.delay_in_seconds).to eql(0)
      end

    end

  end

  describe "#blocks" do

    subject { response.blocks }

    context "when a value is provided in the arguments" do

      let(:blocks) { HttpStub::Server::Stub::Response::BlocksFixture.many }

      it "provides a means of evaluating the blocks" do
        expect(subject).to be_an_instance_of(HttpStub::Server::Stub::Response::Blocks)
      end

      it "contains the provided blocks" do
        expect(subject.to_array).to eql(blocks.map(&:source))
      end

    end

    context "when no blocks are provided" do

      let(:args) { {} }

      it "contains the provided blocks" do
        expect(subject.to_array).to eql([])
      end

    end

  end

  describe "#with_values_from" do

    let(:parameter_value) { "some parameter value"}
    let(:parameters)      { { some_parameter: parameter_value } }
    let(:request)         { HttpStub::Server::RequestFixture.create(parameters: parameters) }

    subject { response.with_values_from(request) }

    context "when no blocks are provided" do

      it "returns a response" do
        expect(subject).to be_an_instance_of(HttpStub::Server::Stub::Response::Response)
      end

      it "returns a response that is unchanged" do
        expect(subject.to_json).to eql(response.to_json)
      end

    end

    context "when blocks are provided" do

      let(:simple_block_headers) { { some_header: "some header value", another_header: "another header value" } }
      let(:simple_block)         do
        lambda do
          {
            status:           400,
            headers:          simple_block_headers,
            body:             "First response body",
            delay_in_seconds: 0
          }
        end
      end
      let(:interpolated_block_headers) do
        { some_header: "some new header value", yet_another_header: "yet another header value" }
      end
      let(:interpolated_block)         do
        lambda do |request|
          {
            status:           201,
            headers:          interpolated_block_headers,
            body:             "Body with parameter: #{request.parameters[:some_parameter]}",
            delay_in_seconds: 7
          }
        end
      end
      let(:blocks) { [ simple_block, interpolated_block ] }

      it "returns a response" do
        expect(subject).to be_an_instance_of(HttpStub::Server::Stub::Response::Response)
      end

      it "returns a response whose values include those within the blocks" do
        expect(subject.to_hash).to include(status: 201, delay_in_seconds: 7)
      end

      it "returns a response with headers that are combined from all blocks" do
        expected_headers = {
          some_header:         "some new header value",
          another_header:      "another header value",
          yet_another_header: "yet another header value"
        }

        expect(subject.to_hash).to include(headers: expected_headers)
      end

      it "returns a response whose values are interpolated from the request" do
        expect(subject.to_hash[:body].to_s).to eql("Body with parameter: #{parameter_value}")
      end

    end

  end

  describe "#serve_on" do

    let(:application) { instance_double(Sinatra::Base) }

    subject { response.serve_on(application) }

    before(:example) { allow(response).to receive(:sleep) }

    it "uses the body to serve the response on the application" do
      expect(response.body).to receive(:serve).with(application, response)

      subject
    end

    it "waits for the delayed time in seconds before serving the response" do
      expect(response).to receive(:sleep).with(delay_in_seconds).ordered
      expect(response.body).to receive(:serve).ordered

      subject
    end

  end

  describe "#to_hash" do

    subject { response.to_hash }

    it "contains the status" do
      expect(subject).to include(status: response.status)
    end

    it "contains the headers" do
      expect(subject).to include(headers: response.headers)
    end

    it "contains the body" do
      expect(subject).to include(body: response.body)
    end

    it "contains the delay in seconds" do
      expect(subject).to include(delay_in_seconds: response.delay_in_seconds)
    end

    context "when blocks are provided" do

      let(:blocks)            { HttpStub::Server::Stub::Response::BlocksFixture.many }
      let(:blocks_as_strings) { blocks.map(&:source) }
      let(:args)              { { blocks: blocks } }

      it "contains a string respresentation of the blocks" do
        expect(subject).to include(blocks: blocks_as_strings)
      end

    end

  end

  describe "#to_json" do

    subject { response.to_json }

    it "is the JSON representation of the responses hash" do
      expect(subject).to eql(response.to_hash.to_json)
    end

  end

end
