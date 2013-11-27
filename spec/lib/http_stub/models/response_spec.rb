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

    it "should have a status of 200" do
      response.status.should eql(200)
    end

    it "should have a body containing OK to visually indicate success to those interacting via a browser" do
      response.body.should match(/OK/)
    end

  end

  describe "::ERROR" do

    let(:response) { HttpStub::Models::Response::ERROR }

    it "should have a status of 404" do
      response.status.should eql(404)
    end

    it "should have a body containing ERROR to visually indicate the error to those interacting via a browser" do
      response.body.should match(/ERROR/)
    end

  end

  describe "#status" do

    context "when a value is provided in the options" do

      context "that is an integer" do

        it "should return the value provided" do
          response.status.should eql(status)
        end

      end

      context "that is an empty string" do

        let(:status) { "" }

        it "should return 200" do
          response.status.should eql(200)
        end

      end

    end

    context "when the status is not provided in the options" do

      let(:response) { HttpStub::Models::Response.new("body" => body, "delay_in_seconds" => delay_in_seconds) }

      it "should return 200" do
        response.status.should eql(200)
      end

    end

  end

  describe "#body" do

    it "should return the value provided in the options" do
      response.body.should eql("A response body")
    end

  end

  describe "#delay_in_seconds" do

    context "when a value is provided in the options" do

      context "that is an integer" do

        it "should return the value" do
          response.delay_in_seconds.should eql(delay_in_seconds)
        end

      end

      context "that is an empty string" do

        let(:delay_in_seconds) { "" }

        it "should return 0" do
          response.delay_in_seconds.should eql(0)
        end

      end

    end

    context "when a value is not provided in the options" do

      let(:response) { HttpStub::Models::Response.new("status" => status, "body" => body) }

      it "should return 0" do
        response.delay_in_seconds.should eql(0)
      end

    end

  end

  describe "#headers" do

    let(:response_header_hash) { response.headers.to_hash }

    it "should be Headers" do
      response.headers.should be_a(HttpStub::Models::Headers)
    end

    context "when headers are provided" do

      context "that include a content type" do

        let(:headers) do
          { "content-type" => "some/content/type", "some_header" => "some value", "another_header" => "another value" }
        end

        it "should return headers including the provided headers" do
          response_header_hash.should eql(headers)
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

        it "should return headers including the provided headers" do
          response_header_hash.should include(headers)
        end

        it "should return headers including json as the default response content type" do
          response_header_hash.should include("content-type" => "application/json")
        end

      end

    end

    context "when no headers are provided" do

      let(:headers) { nil }

      it "should return headers containing json as the default response content type" do
        response_header_hash.should eql("content-type" => "application/json")
      end

    end

  end

  describe "#empty?" do

    context "when the response is EMPTY" do

      it "should return true" do
        HttpStub::Models::Response::EMPTY.should be_empty
      end

    end

    context "when the response is not EMPTY but contains no values" do

      it "should return true" do
        HttpStub::Models::Response.new.should be_empty
      end

    end

    context "when the response is not EMPTY" do

      it "should return false" do
        HttpStub::Models::Response::SUCCESS.should_not be_empty
      end

    end

  end

end
