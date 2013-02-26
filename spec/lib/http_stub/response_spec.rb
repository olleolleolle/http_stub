describe HttpStub::Response do

  let(:response) { HttpStub::Response.new("status" => 202, "body" => "A response body")}

  describe "::SUCCESS" do

    let(:response) { HttpStub::Response::SUCCESS }

    it "should have a status of 200" do
      response.status.should eql(200)
    end

    it "should have a body containing OK to visually indicate success to those interacting via a browser" do
      response.body.should match(/OK/)
    end

  end

  describe "::ERROR" do

    let(:response) { HttpStub::Response::ERROR }

    it "should have a status of 404" do
      response.status.should eql(404)
    end

    it "should have a body containing ERROR to visually indicate the error to those interacting via a browser" do
      response.body.should match(/ERROR/)
    end

  end

  describe "::EMPTY" do

    let(:response) { HttpStub::Response::EMPTY }

    it "should have a nil status" do
      response.status.should be_nil
    end

    it "should have a nil body" do
      response.body.should be_nil
    end

  end

  describe "#status" do

    it "should return the value provided in the options" do
      response.status.should eql(202)
    end

  end

  describe "#body" do

    it "should return the value provided in the options" do
      response.body.should eql("A response body")
    end

  end

  describe "#empty?" do

    describe "when the response is EMPTY" do

      it "should return true" do
        HttpStub::Response::EMPTY.should be_empty
      end

    end

    describe "when the response is not EMPTY but contains no values" do

      it "should return true" do
        HttpStub::Response.new.should be_empty
      end

    end

    describe "when the response is not EMPTY" do

      it "should return false" do
        HttpStub::Response::SUCCESS.should_not be_empty
      end

    end

  end

end
