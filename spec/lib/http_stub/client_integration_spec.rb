describe HttpStub::Client do
  include_context "server integration"

  class TestClient
    include HttpStub::Client

    host "localhost"
    port 8001
  end

  let(:client) { TestClient.new }

  after(:each) { client.clear! }

  describe "when a response for a request is stubbed" do

    describe "that contains no parameters" do

      before(:each) { client.stub_response!("/a_path", method: :get,
                                                       response: { status: 200, body: "Some body" }) }

      describe "and that request is made" do

        let(:response) { Net::HTTP.get_response("localhost", "/a_path", 8001) }

        it "should replay the stubbed response" do
          response.code.should eql("200")
          response.body.should eql("Some body")
        end

      end

      describe "and the stub is cleared" do

        before(:each) { client.clear! }

        describe "and the original request is made" do

          let(:response) { Net::HTTP.get_response("localhost", "/a_path", 8001) }

          it "should respond with a 404 status code" do
            response.code.should eql("404")
          end

        end

      end

    end

    describe "that contains parameters" do

      before(:each) { client.stub_response!("/a_path", method: :get, parameters: { key: "value" },
                                                       response: { status: 200, body: "Some body" }) }

      describe "and that request is made" do

        let(:response) { Net::HTTP.get_response("localhost", "/a_path?key=value", 8001) }

        it "should replay the stubbed response" do
          response.code.should eql("200")
          response.body.should eql("Some body")
        end

      end

      describe "and a request with different parameters is made" do

        let(:response) { Net::HTTP.get_response("localhost", "/a_path?key=another_value", 8001) }

        it "should respond with a 404 status code" do
          response.code.should eql("404")
        end

      end

    end

  end

end
