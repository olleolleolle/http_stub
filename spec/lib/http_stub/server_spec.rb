describe HttpStub::Server do
  include Rack::Test::Methods

  let(:app) { HttpStub::Server.new }

  let(:registry) { double(HttpStub::Registry).as_null_object }
  before(:each) { HttpStub::Registry.stub!(:new).and_return(registry) }

  let(:response) { last_response }
  let(:response_body) { response.body.to_s }

  describe "when a stub request is received" do

    it "should register a stub encapsulating the request" do
      stub = double(HttpStub::Stub)
      HttpStub::Stub.should_receive(:new).and_return(stub)
      registry.should_receive(:add).with(stub, anything)

      issue_stub_request
    end

  end

  describe "when a replay request is received" do

    describe "and the request has been stubbed" do

      before(:each) do
        registry.stub!(:find_for).and_return(
            double(HttpStub::Stub, response: double("StubResponse", status: 500, body: "Some text")))
      end

      it "should respond with the configured status" do
        get "/a_path"

        response.status.should eql(500)
      end

      it "should respond with the configured body" do
        get "/a_path"

        response_body.should eql("Some text")
      end

    end

    describe "and the request has not been stubbed" do

      before(:each) do
        registry.stub!(:find_for).and_return(nil)
      end

      it "should respond with a 404 status code" do
        get "/a_path"

        response.status.should eql(404)
      end

    end

  end

  describe "when a request to clear the stub has been received" do

    it "should clear the contents of the registry" do
      registry.should_receive(:clear)

      delete "/stubs"
    end

    it "should respond with a 200 status code" do
      delete "/stubs"

      response.status.should eql(200)
    end

  end

  def issue_stub_request
    post "/stub", {
        "uri" => "/a_path",
        "method" => "a method",
        "response" => {
            "status" => 200,
            "body" => "Foo"
        }
    }.to_json
  end

end
