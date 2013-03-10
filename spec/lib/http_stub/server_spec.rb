describe HttpStub::Server do
  include Rack::Test::Methods

  let(:response) { last_response }
  let(:response_body) { response.body.to_s }

  let(:stub_registry) { double(HttpStub::Models::Registry).as_null_object }
  let(:stub_activator_registry) { double(HttpStub::Models::Registry).as_null_object }

  let(:stub_controller) { double(HttpStub::Controllers::StubController).as_null_object }
  let(:stub_activator_controller) { double(HttpStub::Controllers::StubActivatorController).as_null_object }

  let(:app) { HttpStub::Server.new }

  before(:each) do
    HttpStub::Models::Registry.stub!(:new).with("stub").and_return(stub_registry)
    HttpStub::Models::Registry.stub!(:new).with("stub_activator").and_return(stub_activator_registry)
    HttpStub::Controllers::StubController.stub!(:new).and_return(stub_controller)
    HttpStub::Controllers::StubActivatorController.stub!(:new).and_return(stub_activator_controller)
  end

  describe "when a stub insertion is received" do

    it "should register the insertion via the stub controller" do
      stub_controller.should_receive(:register).and_return(HttpStub::Models::Response::SUCCESS)

      issue_stub_request
    end

    it "should respond with the response provided by the controller" do
      stub_controller.stub!(:register).and_return(HttpStub::Models::Response.new("status" => 202, "body" => ""))

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

  describe "when a stub activator insertion request is received" do

    it "should register the insertion via the stub activator controller" do
      stub_activator_controller.should_receive(:register).and_return(HttpStub::Models::Response::SUCCESS)

      issue_stub_activator_request
    end

    it "should respond with the response provided by the controller" do
      stub_activator_controller.stub!(:register).and_return(HttpStub::Models::Response.new("status" => 302, "body" => ""))

      issue_stub_activator_request

      response.status.should eql(302)
    end

    def issue_stub_activator_request
      post "/stubs/activators", {
          "activation_uri" => "/an_activation_path",
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

  describe "when a request to clear the stub activators has been received" do

    it "should delegate clearing to the stub activator controller" do
      stub_activator_controller.should_receive(:clear)

      delete "/stubs/activators"
    end

    it "should respond with a 200 status code" do
      delete "/stubs/activators"

      response.status.should eql(200)
    end

  end

  describe "when another type of request is received" do

    describe "and the stub controller replays a response" do

      before(:each) do
        stub_controller.stub!(:replay).and_return(HttpStub::Models::Response.new("status" => 222, "body" => "Some body"))
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
        stub_controller.stub!(:replay).and_return(HttpStub::Models::Response::EMPTY)
      end

      describe "but the stub activator controller activates a stub" do

        before(:each) do
          stub_activator_controller.stub!(:activate).and_return(HttpStub::Models::Response.new("status" => 300, "body" => "A body"))
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

      describe "and the stub activator controller does not activate a stub" do

        before(:each) do
          stub_activator_controller.stub!(:activate).and_return(HttpStub::Models::Response::EMPTY)
        end

        it "should respond with a 404 status code" do
          get "/a_path"

          response.status.should eql(404)
        end

      end

    end

  end

end
