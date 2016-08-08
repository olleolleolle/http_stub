describe HttpStub::Server::Response do

  shared_examples_for "an ok response" do

    it "has a status of 200" do
      expect(subject.status).to eql(200)
    end

    it "has a body containing OK to visually indicate success to those interacting via a browser" do
      expect(subject.body).to match(/OK/)
    end

  end

  describe "::ok" do

    subject { described_class.ok }

    it_behaves_like "an ok response"

    context "when options are provided" do

      let(:headers) { { "response_header_key" => "response header value" } }
      let(:body)    { "response body" }
      let(:opts)    { { "headers" => headers, "body" => body } }

      subject { HttpStub::Server::Response::ok(opts) }

      it "establishes any headers provided" do
        expect(subject.headers).to eql(headers)
      end

      it "establishes any body provided" do
        expect(subject.body).to eql(body)
      end

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
      expect(subject.body).to match(/NOT FOUND/)
    end

  end

  describe "::EMPTY" do

    subject { HttpStub::Server::Response::EMPTY }

    it "has a status of 200" do
      expect(subject.status).to eql(200)
    end

    it "has no body" do
      expect(subject.body.provided?).to be(false)
    end

  end

end
