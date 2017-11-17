describe HttpStub::Server::Response do

  shared_examples_for "an ok response" do

    it "has a status of 200" do
      expect(subject.status).to eql(200)
    end

    it "has a body containing OK to visually indicate success to those interacting via a browser" do
      expect(subject.body.to_s).to include("OK")
    end

  end

  describe "::ok" do

    subject { described_class.ok }

    it_behaves_like "an ok response"

    context "when options are provided" do

      let(:headers)          { { response_header_key: "response header value" } }
      let(:body)             { "response body" }
      let(:delay_in_seconds) { "response body" }
      let(:opts)             { { headers: headers, body: body, delay_in_seconds: delay_in_seconds } }

      subject { described_class.ok(opts) }

      it "establishes any headers provided" do
        expect(subject.headers.to_json).to eql(headers.to_json)
      end

      it "establishes any body provided" do
        expect(subject.body.to_s).to eql(body)
      end

      it "establishes any delay provided" do
        expect(subject.delay_in_seconds).to eql(delay_in_seconds)
      end

    end

  end

  describe "::invalid_request" do

    let(:cause_message) { "Some error message" }
    let(:cause)         { StandardError.new(cause_message) }

    subject { described_class.invalid_request(cause) }

    it "has a status of 400" do
      expect(subject.status).to eql(400)
    end

    it "has a body containing the message of the cause" do
      expect(subject.body.to_s).to include(cause_message)
    end

  end

  describe "::OK" do

    subject { HttpStub::Server::Response::OK }

    it_behaves_like "an ok response"

  end

  describe "::NOT_FOUND" do

    subject { HttpStub::Server::Response::NOT_FOUND }

    it "has a status of 404" do
      expect(subject.status).to eql(404)
    end

    it "has a body containing NOT FOUND to visually indicate the response to those interacting via a browser" do
      expect(subject.body.to_s).to include("NOT FOUND")
    end

  end

  describe "::EMPTY" do

    subject { HttpStub::Server::Response::EMPTY }

    it "has a status of 200" do
      expect(subject.status).to eql(200)
    end

    it "has an empty body" do
      expect(subject.body.to_s).to be_empty
    end

  end

end
