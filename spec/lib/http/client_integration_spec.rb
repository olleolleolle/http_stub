describe Http::Stub::Client do
  include_context "server integration"

  class TestClient
    include Http::Stub::Client

    host "localhost"
    port 8001
  end

  let(:client) { TestClient.new }

  describe "when a response for a request is stubbed" do

    before(:each) do
      client.stub_response!("/a_path", method: :get, status: 200, body: "Some body")
    end

    describe "and that request is made" do

      let(:response) { Net::HTTP.get_response("localhost", "/a_path", 8001) }

      it "should replay the stubbed response" do
        response.code.should eql("200")
        response.body.should eql("Some body")
      end

    end

  end

end
