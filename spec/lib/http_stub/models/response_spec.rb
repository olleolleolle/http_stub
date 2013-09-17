describe HttpStub::Models::Response do

  let(:status) { 202 }
  let(:body) { "A response body" }
  let(:delay_in_seconds) { 18 }

  let(:response) do
    HttpStub::Models::Response.new("status" => status, "body" => body, "delay_in_seconds" => delay_in_seconds)
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

  describe "#empty?" do

    describe "when the response is EMPTY" do

      it "should return true" do
        HttpStub::Models::Response::EMPTY.should be_empty
      end

    end

    describe "when the response is not EMPTY but contains no values" do

      it "should return true" do
        HttpStub::Models::Response.new.should be_empty
      end

    end

    describe "when the response is not EMPTY" do

      it "should return false" do
        HttpStub::Models::Response::SUCCESS.should_not be_empty
      end

    end

  end

end
