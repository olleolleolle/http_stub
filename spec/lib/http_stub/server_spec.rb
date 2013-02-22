describe HttpStub::Server do
  include Rack::Test::Methods

  let(:response) { last_response }
  let(:response_body) { response.body.to_s }

  let(:stub_registry) { double(HttpStub::Models::Registry).as_null_object }
  let(:alias_registry) { double(HttpStub::Models::Registry).as_null_object }

  let(:stub_controller) { double(HttpStub::Controllers::StubController).as_null_object }
  let(:alias_controller) { double(HttpStub::Controllers::AliasController).as_null_object }

  let(:app) { HttpStub::Server.new }

  before(:each) do
    HttpStub::Models::Registry.stub!(:new).with("stub").and_return(stub_registry)
    HttpStub::Models::Registry.stub!(:new).with("alias").and_return(alias_registry)
    HttpStub::Controllers::StubController.stub!(:new).and_return(stub_controller)
    HttpStub::Controllers::AliasController.stub!(:new).and_return(alias_controller)
  end

  describe "when a stub insertion is received" do

    it "should register the insertion via the stub controller" do
      stub_controller.should_receive(:register).and_return(HttpStub::Response::SUCCESS)

      issue_stub_request
    end

    it "should respond with the response provided by the controller" do
      stub_controller.stub!(:register).and_return(HttpStub::Response.new(status: 202, body: ""))

      issue_stub_request

      response.status.should eql(202)
    end

    def issue_stub_request
      post "/stubs", {
          "uri" => "/a_path",
          "method" => "a method",
          "response" => {
              "status" => 200,
              "body" => "Foo"
          }
      }.to_json
    end

  end

  describe "when a stub alias insertion request is received" do

    it "should register the insertion via the alias controller" do
      alias_controller.should_receive(:register).and_return(HttpStub::Response::SUCCESS)

      issue_stub_alias_request
    end

    it "should respond with the response provided by the controller" do
      alias_controller.stub!(:register).and_return(HttpStub::Response.new(status: 302, body: ""))

      issue_stub_alias_request

      response.status.should eql(302)
    end

    def issue_stub_alias_request
      post "/stubs/aliases", {
          "alias_uri" => "/an_alias_path",
          "uri" => "/a_path",
          "method" => "a method",
          "response" => {
              "status" => 200,
              "body" => "Foo"
          }
      }.to_json
    end

  end

  describe "when a request to clear the stubs has been received" do

    it "should delegate clearing to the stub controller" do
      stub_controller.should_receive(:clear)

      delete "/stubs"
    end

    it "should respond with a 200 status code" do
      delete "/stubs"

      response.status.should eql(200)
    end

  end

  describe "when a request to clear the stub aliases has been received" do

    it "should delegate clearing to the stub controller" do
      alias_controller.should_receive(:clear)

      delete "/stubs/aliases"
    end

    it "should respond with a 200 status code" do
      delete "/stubs/aliases"

      response.status.should eql(200)
    end

  end

  describe "when another type of request is received" do

    describe "and the stub controller replays a response" do

      before(:each) do
        stub_controller.stub!(:replay).and_return(HttpStub::Response.new(status: 222, body: "Some body"))
      end

      it "should respond with the replay status code" do
        get "/a_path"

        response.status.should eql(222)
      end

      it "should respond with the replay body" do
        get "/a_path"

        response_body.should eql("Some body")
      end

    end

    describe "and the stub controller does not replay a response" do

      before(:each) do
        stub_controller.stub!(:replay).and_return(HttpStub::Response::EMPTY)
      end

      describe "but the alias controller activates a stub" do

        before(:each) do
          alias_controller.stub!(:activate).and_return(HttpStub::Response.new(status: 300, body: "A body"))
        end

        it "should respond with the activation response status code" do
          get "/a_path"

          response.status.should eql(300)
        end

        it "should respond with the activation response body" do
          get "/a_path"

          response_body.should eql("A body")
        end

      end

      describe "and the alias controller does not activate a stub" do

        before(:each) do
          alias_controller.stub!(:activate).and_return(HttpStub::Response::EMPTY)
        end

        it "should respond with a 404 status code" do
          get "/a_path"

          response.status.should eql(404)
        end

      end

    end

  end

end
