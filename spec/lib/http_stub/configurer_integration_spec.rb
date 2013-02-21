describe HttpStub::Configurer do
  include_context "server integration"

  before(:all) do
    class TestConfigurer
      include HttpStub::Configurer

      host "localhost"
      port 8001

      stub_alias "/an_alias", "/path1", method: :get, response: { status: 200, body: "Stub alias body" }
    end
  end

  let(:configurer) { TestConfigurer.new }

  after(:each) { configurer.clear! }

  describe "when a stub alias is activated" do

    before(:each) { Net::HTTP.get_response("localhost", "/an_alias", 8001) }

    describe "and the stub request is made" do

      let(:response) { Net::HTTP.get_response("localhost", "/path1", 8001) }

      it "should replay the stubbed response" do
        response.code.should eql("200")
        response.body.should eql("Stub alias body")
      end

    end

  end

  describe "when a stub alias is not activated" do

    describe "and the stub request is made" do

      let(:response) { Net::HTTP.get_response("localhost", "/path1", 8001) }

      it "should respond with a 404 status code" do
        response.code.should eql("404")
      end

    end

  end

  describe "when a response for a request is stubbed" do

    describe "that contains no parameters" do

      before(:each) do
        configurer.stub_response!("/path2", method: :get, response: { status: 201, body: "Stub body" })
      end

      describe "and that request is made" do

        let(:response) { Net::HTTP.get_response("localhost", "/path2", 8001) }

        it "should replay the stubbed response" do
          response.code.should eql("201")
          response.body.should eql("Stub body")
        end

      end

      describe "and the stub is cleared" do

        before(:each) { configurer.clear! }

        describe "and the original request is made" do

          let(:response) { Net::HTTP.get_response("localhost", "/path2", 8001) }

          it "should respond with a 404 status code" do
            response.code.should eql("404")
          end

        end

      end

    end

    describe "that contains parameters" do

      before(:each) do
        configurer.stub_response!("/path3", method: :get, parameters: { key: "value" },
                                                          response: { status: 202, body: "Another stub body" })
      end

      describe "and that request is made" do

        let(:response) { Net::HTTP.get_response("localhost", "/path3?key=value", 8001) }

        it "should replay the stubbed response" do
          response.code.should eql("202")
          response.body.should eql("Another stub body")
        end

      end

      describe "and a request with different parameters is made" do

        let(:response) { Net::HTTP.get_response("localhost", "/path3?key=another_value", 8001) }

        it "should respond with a 404 status code" do
          response.code.should eql("404")
        end

      end

    end

  end

end
