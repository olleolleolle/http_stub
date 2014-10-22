describe HttpStub::Server do
  include Rack::Test::Methods

  let(:response)      { last_response }
  let(:response_body) { response.body.to_s }

  let(:stub_registry)           { instance_double(HttpStub::Models::StubRegistry).as_null_object }
  let(:stub_activator_registry) { instance_double(HttpStub::Models::Registry).as_null_object }

  let(:stub_controller)           { instance_double(HttpStub::Controllers::StubController).as_null_object }
  let(:stub_activator_controller) { instance_double(HttpStub::Controllers::StubActivatorController).as_null_object }

  let(:app) { HttpStub::Server.new! }

  before(:example) do
    allow(HttpStub::Models::StubRegistry).to receive(:new).and_return(stub_registry)
    allow(HttpStub::Models::Registry).to receive(:new).with("stub_activator").and_return(stub_activator_registry)
    allow(HttpStub::Controllers::StubController).to receive(:new).and_return(stub_controller)
    allow(HttpStub::Controllers::StubActivatorController).to receive(:new).and_return(stub_activator_controller)
  end

  context "when a stub insertion request is received" do

    subject do
      post "/stubs", {
        uri: "/a_path", method: "a method",
        response: { status: 200, body: "Foo" }
      }.to_json
    end

    it "registers the insertion via the stub controller" do
      expect(stub_controller).to receive(:register).and_return(HttpStub::Models::Response::SUCCESS)

      subject
    end

    it "responds with the response provided by the controller" do
      allow(stub_controller).to receive(:register).and_return(HttpStub::Models::Response.new("status" => 202, "body" => ""))

      subject

      expect(response.status).to eql(202)
    end

  end

  context "when a request to commit the stubs to memory is received" do

    subject { post "/stubs/memory" }

    it "remembers the stubs in the stub registry" do
      expect(stub_registry).to receive(:remember)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  context "when a request to recall the stubs in memory is received" do

    subject { get "/stubs/memory" }

    it "recalls the stubs remembered by the stub registry" do
      expect(stub_registry).to receive(:recall)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  context "when a request to clear the stubs has been received" do

    subject { delete "/stubs" }

    it "delegates clearing to the stub controller" do
      expect(stub_controller).to receive(:clear)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  context "when a stub activator insertion request is received" do

    subject do
      post "/stubs/activators", {
        activation_uri: "/an_activation_path", uri: "/a_path", method: "a method",
        response: { status: 200, body: "Foo" }
      }.to_json
    end

    it "registers the insertion via the stub activator controller" do
      expect(stub_activator_controller).to receive(:register).and_return(HttpStub::Models::Response::SUCCESS)

      subject
    end

    it "responds with the response provided by the controller" do
      allow(stub_activator_controller).to(
        receive(:register).and_return(HttpStub::Models::Response.new("status" => 302, "body" => ""))
      )

      subject

      expect(response.status).to eql(302)
    end

  end

  context "when a request to clear the stub activators has been received" do

    subject { delete "/stubs/activators" }

    it "delegates clearing to the stub activator controller" do
      expect(stub_activator_controller).to receive(:clear)

      subject
    end

    it "responds with a 200 status code" do
      subject

      expect(response.status).to eql(200)
    end

  end

  context "when another type of request is received" do

    subject { get "/a_path" }

    context "and the stub controller replays a response" do

      let(:controller_response) do
        HttpStub::Models::Response.new(
          "status" =>  222,
          "headers" => { "content-type" => "application/xhtml" },
          "body" =>    "Some body"
        )
      end

      before(:example) { allow(stub_controller).to receive(:replay).and_return(controller_response) }

      it "responds with the replay status code" do
        subject

        expect(response.status).to eql(222)
      end

      it "responds with the replay body" do
        subject

        expect(response_body).to eql("Some body")
      end

      it "responds with the replay content type" do
        subject

        expect(response.content_type).to eql("application/xhtml")
      end

      it "allows the request pipeline to process the response before the processing of the request halts" do
        expect(HttpStub::Models::RequestPipeline).to receive(:before_halt).with(controller_response)

        subject
      end

    end

    context "and the stub controller does not replay a response" do

      before(:example) do
        allow(stub_controller).to receive(:replay).and_return(HttpStub::Models::Response::EMPTY)
      end

      context "but the stub activator controller activates a stub" do

        before(:example) do
          allow(stub_activator_controller).to receive(:activate).and_return(
            HttpStub::Models::Response.new("status" => 300, "body" => "A body")
          )
        end

        it "responds with the activation response status code" do
          subject

          expect(response.status).to eql(300)
        end

        it "responds with the activation response body" do
          subject

          expect(response_body).to eql("A body")
        end

      end

      context "and the stub activator controller does not activate a stub" do

        before(:example) do
          allow(stub_activator_controller).to receive(:activate).and_return(HttpStub::Models::Response::EMPTY)
        end

        it "responds with a 404 status code" do
          subject

          expect(response.status).to eql(404)
        end

      end

    end

  end

end
