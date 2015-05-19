describe HttpStub::Models::Response do

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

  describe "::EMPTY" do

    let(:response) { HttpStub::Models::Response::EMPTY }

    it "is empty" do
      expect(response.empty?).to be(true)
    end

  end

end
