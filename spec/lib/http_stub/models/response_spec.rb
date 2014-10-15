describe HttpStub::Models::Response do

  let(:status) { 202 }
  let(:headers) { nil }
  let(:body) { "A response body" }
  let(:delay_in_seconds) { 18 }

  let(:response) do
    HttpStub::Models::Response.new(
      "status" => status, "headers" => headers, "body" => body, "delay_in_seconds" => delay_in_seconds
    )
  end

  describe "::SUCCESS" do

    let(:response) { HttpStub::Models::Response::SUCCESS }

    it "has a status of 200" do
      expect(response.status).to eql(200)
    end

    it "has a body containing OK to visually indicate success to those interacting via a browser" do
      expect(response.body).to match(/OK/)
    end

  end

  describe "::ERROR" do

    let(:response) { HttpStub::Models::Response::ERROR }

    it "has a status of 404" do
      expect(response.status).to eql(404)
    end

    it "has a body containing ERROR to visually indicate the error to those interacting via a browser" do
      expect(response.body).to match(/ERROR/)
    end

  end

  describe "#status" do

    context "when a value is provided in the arguments" do

      context "that is an integer" do

        it "returns the value provided" do
          expect(response.status).to eql(status)
        end

      end

      context "that is an empty string" do

        let(:status) { "" }

        it "returns 200" do
          expect(response.status).to eql(200)
        end

      end

    end

    context "when the status is not provided in the arguments" do

      let(:response) { HttpStub::Models::Response.new("body" => body, "delay_in_seconds" => delay_in_seconds) }

      it "returns 200" do
        expect(response.status).to eql(200)
      end

    end

  end

  describe "#body" do

    it "returns the value provided in the arguments" do
      expect(response.body).to eql("A response body")
    end

  end

  describe "#delay_in_seconds" do

    context "when a value is provided in the arguments" do

      context "that is an integer" do

        it "returns the value" do
          expect(response.delay_in_seconds).to eql(delay_in_seconds)
        end

      end

      context "that is an empty string" do

        let(:delay_in_seconds) { "" }

        it "returns 0" do
          expect(response.delay_in_seconds).to eql(0)
        end

      end

    end

    context "when a value is not provided in the arguments" do

      let(:response) { HttpStub::Models::Response.new("status" => status, "body" => body) }

      it "returns 0" do
        expect(response.delay_in_seconds).to eql(0)
      end

    end

  end

  describe "#headers" do

    let(:response_header_hash) { response.headers.to_hash }

    it "is Headers" do
      expect(response.headers).to be_a(HttpStub::Models::Headers)
    end

    context "when headers are provided" do

      context "that include a content type" do

        let(:headers) do
          { "content-type" => "some/content/type", "some_header" => "some value", "another_header" => "another value" }
        end

        it "returns headers including the provided headers" do
          expect(response_header_hash).to eql(headers)
        end

      end

      context "that do not include a content type" do

        let(:headers) do
          {
            "some_header" => "some value",
            "another_header" => "another value",
            "yet_another_header" => "yet another value"
          }
        end

        it "returns headers including the provided headers" do
          expect(response_header_hash).to include(headers)
        end

        it "returns headers including json as the default response content type" do
          expect(response_header_hash).to include("content-type" => "application/json")
        end

      end

    end

    context "when no headers are provided" do

      let(:headers) { nil }

      it "returns headers containing json as the default response content type" do
        expect(response_header_hash).to eql("content-type" => "application/json")
      end

    end

  end

  describe "#empty?" do

    context "when the response is EMPTY" do

      it "returns true" do
        expect(HttpStub::Models::Response::EMPTY).to be_empty
      end

    end

    context "when the response is not EMPTY but contains no values" do

      it "returns true" do
        expect(HttpStub::Models::Response.new).to be_empty
      end

    end

    context "when the response is not EMPTY" do

      it "returns false" do
        expect(HttpStub::Models::Response::SUCCESS).not_to be_empty
      end

    end

  end

end
