describe HttpStub::Configurer, "when the server is running" do
  include_context "server integration"

  let(:configurer) { HttpStub::Examples::ConfigurerWithActivator.new }

  after(:each) do
    configurer.clear_stubs!
    configurer.class.clear_activators!
  end

  describe "and the configurer is initialized" do

    before(:each) { configurer.class.initialize! }

    describe "and a stub is activated" do

      before(:each) { configurer.activate!("/an_activator") }

      describe "and the stub request is made" do

        let(:response) { Net::HTTP.get_response("localhost", "/path1", 8001) }

        it "should replay the stubbed response" do
          response.code.should eql("200")
          response.body.should eql("Stub activator body")
        end

      end

    end

    describe "and a stub is not activated" do

      describe "and the stub request is made" do

        let(:response) { Net::HTTP.get_response("localhost", "/path1", 8001) }

        it "should respond with a 404 status code" do
          response.code.should eql("404")
        end

      end

    end

    describe "and an after_initialize callback is defined" do

      let(:configurer) { HttpStub::Examples::ConfigurerWithInitializationObserver.new }

      it "the callback should be invoked" do
        response = Net::HTTP.get_response("localhost", "/an_initialization_stub", 8001)

        response.code.should eql("201")
        response.body.should eql("Initialization stub body")
      end

    end

  end

  describe "and the configurer is uninitialized" do

    describe "and an attempt is made to activate a stub" do

      let(:response) { Net::HTTP.get_response("localhost", "/path1", 8001) }

      it "should respond raise an exception indicating the activator is not configured" do
        lambda { configurer.activate!("/an_activator") }.should raise_error(/activator \/an_activator not configured/i)
      end

    end

  end

  describe "when a response for a request is stubbed" do

    describe "that contains no headers or parameters" do

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

    describe "that contains headers" do

      before(:each) do
        configurer.stub_response!("/path3", method: :get, headers: { key: "value" },
                                                          response: { status: 202, body: "Another stub body" })
      end

      describe "and that request is made" do

        let(:response) { HTTParty.get("http://localhost:8001/path3", headers: { "key" => "value" }) }

        it "should replay the stubbed response" do
          response.code.should eql(202)
          response.body.should eql("Another stub body")
        end

      end

      describe "and a request with different headers is made" do

        let(:response) { HTTParty.get("http://localhost:8001/path3", headers: { "key" => "another_value" }) }

        it "should respond with a 404 status code" do
          response.code.should eql(404)
        end

      end

    end

    describe "that contains parameters" do

      before(:each) do
        configurer.stub_response!("/path4", method: :get, parameters: { key: "value" },
                                                          response: { status: 202, body: "Another stub body" })
      end

      describe "and that request is made" do

        let(:response) { Net::HTTP.get_response("localhost", "/path4?key=value", 8001) }

        it "should replay the stubbed response" do
          response.code.should eql("202")
          response.body.should eql("Another stub body")
        end

      end

      describe "and a request with different parameters is made" do

        let(:response) { Net::HTTP.get_response("localhost", "/path4?key=another_value", 8001) }

        it "should respond with a 404 status code" do
          response.code.should eql("404")
        end

      end

    end

  end

end
