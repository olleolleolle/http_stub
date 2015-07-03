describe HttpStub::Server::Response do

  shared_examples_for "a success response" do

    it "has a status of 200" do
      expect(subject.status).to eql(200)
    end

    it "has a body containing OK to visually indicate success to those interacting via a browser" do
      expect(subject.body).to match(/OK/)
    end

  end

  describe "::success" do

    subject { HttpStub::Server::Response::success }

    it_behaves_like "a success response"

    context "when headers are provided" do

      let(:headers) { { "response_header_key" => "response header value" } }

      subject { HttpStub::Server::Response::success(headers) }

      it "established the headers" do
        expect(subject.headers).to eql(headers)
      end

    end

  end

  describe "::SUCCESS" do

    subject { HttpStub::Server::Response::SUCCESS }

    it_behaves_like "a success response"

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
      expect(subject.body).to be(nil)
    end

    it "is empty" do
      expect(subject).to be_empty
    end

  end

end
