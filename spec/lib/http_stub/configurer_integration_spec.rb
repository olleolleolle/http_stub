describe HttpStub::Configurer, "when the server is running" do
  include_context "server integration"

  let(:configurer) { HttpStub::Examples::ConfigurerWithAlias.new }

  after(:each) do
    configurer.clear!
    configurer.class.clear_aliases!
  end

  describe "and the configurer is initialized" do

    before(:each) { configurer.class.initialize! }

    describe "and a stub alias is activated" do

      before(:each) { configurer.activate!("/an_alias") }

      describe "and the stub request is made" do

        let(:response) { Net::HTTP.get_response("localhost", "/path1", 8001) }

        it "should replay the stubbed response" do
          response.code.should eql("200")
          response.body.should eql("Stub alias body")
        end

      end

    end

    describe "and a stub alias is not activated" do

      describe "and the stub request is made" do

        let(:response) { Net::HTTP.get_response("localhost", "/path1", 8001) }

        it "should respond with a 404 status code" do
          response.code.should eql("404")
        end

      end

    end

  end

  describe "and the configurer is uninitialized" do

    describe "and an attempt is made to activate a stub alias" do

      let(:response) { Net::HTTP.get_response("localhost", "/path1", 8001) }

      it "should respond raise an exception indicating the alias is not configured" do
        lambda { configurer.activate!("/an_alias") }.should raise_error(/alias \/an_alias not configured/i)
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
