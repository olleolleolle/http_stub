describe HttpStub::Response do

  describe "::SUCCESS" do

    let(:response) { HttpStub::Response::SUCCESS }

    it "should have a status of 200" do
      response.status.should eql(200)
    end

    it "should have an empty body" do
      response.body.should eql("")
    end

  end

  describe "::ERROR" do

    let(:response) { HttpStub::Response::ERROR }

    it "should have a status of 404" do
      response.status.should eql(404)
    end

    it "should have an empty body" do
      response.body.should eql("")
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
