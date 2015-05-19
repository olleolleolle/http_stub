describe HttpStub::Server do
  include Rack::Test::Methods

  let(:response)      { last_response }
  let(:response_body) { response.body.to_s }

  let(:stub_registry)           { instance_double(HttpStub::Models::StubRegistry).as_null_object }
  let(:stub_activator_registry) { instance_double(HttpStub::Models::Registry).as_null_object }

  let(:stub_controller)           { instance_double(HttpStub::Controllers::StubController).as_null_object }
  let(:stub_activator_controller) { instance_double(HttpStub::Controllers::StubActivatorController).as_null_object }

  let(:response_pipeline) { instance_double(HttpStub::Models::ResponsePipeline, process: nil) }

  let(:app) { HttpStub::Server.new! }

  before(:example) do
    allow(HttpStub::Models::StubRegistry).to receive(:new).and_return(stub_registry)
    allow(HttpStub::Models::Registry).to receive(:new).with("stub_activator").and_return(stub_activator_registry)
    allow(HttpStub::Controllers::StubController).to receive(:new).and_return(stub_controller)
    allow(HttpStub::Controllers::StubActivatorController).to receive(:new).and_return(stub_activator_controller)
    allow(HttpStub::Models::ResponsePipeline).to receive(:new).and_return(response_pipeline)
  end

  context "when a stub insertion request is received" do

    let(:stub_controller_response) { instance_double(HttpStub::Models::StubResponse::Base) }

    subject do
      post "/stubs", { uri: "/a_path", method: "a method", response: { status: 200, body: "Foo" } }.to_json
    end

    before(:example) { allow(stub_controller).to receive(:register).and_return(stub_controller_response) }

    it "registers the inserted stub via the controller" do
      expect(stub_controller).to receive(:register).and_return(stub_controller_response)

      subject
    end

    it "processes the stub controllers response via the response pipeline" do
      expect(response_pipeline).to receive(:process).with(stub_controller_response)

      subject
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

    let(:stub_activator_response) { instance_double(HttpStub::Models::StubResponse::Base) }

    before(:example) { allow(stub_activator_controller).to receive(:register).and_return(stub_activator_response) }

    subject do
      post "/stubs/activators", {
        activation_uri: "/an_activation_path", uri: "/a_path", method: "a method",
        response: { status: 200, body: "Foo" }
      }.to_json
    end

    it "registers the insertion via the stub activator controller" do
      expect(stub_activator_controller).to receive(:register).and_return(stub_activator_response)

      subject
    end

    it "processes the stub activators response via the response pipeline" do
      expect(response_pipeline).to receive(:process).with(stub_activator_response)

      subject
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

    let(:stub_response) { instance_double(HttpStub::Models::StubResponse::Base) }

    subject { get "/a_path" }

    before(:example) { allow(stub_controller).to receive(:replay).and_return(stub_response) }

    context "and the stub controller replays a response" do

      before(:example) { allow(stub_response).to receive(:empty?).and_return(false) }

      it "processes the response via the response pipeline" do
        expect(response_pipeline).to receive(:process).with(stub_response)

        subject
      end

    end

    context "and the stub controller does not replay a response" do

      let(:stub_activator_response) { double(HttpStub::Models::StubResponse::Base, serve_on: nil) }

      before(:example) do
        allow(stub_response).to receive(:empty?).and_return(true)
        allow(stub_activator_controller).to receive(:activate).and_return(stub_activator_response)
      end

      context "but the stub activator controller activates a stub" do

        before(:each) { allow(stub_activator_response).to receive(:empty?).and_return(false) }

        it "processes the stub activator response via the response pipeline" do
          expect(response_pipeline).to receive(:process).with(stub_activator_response)

          subject
        end

      end

      context "and the stub activator controller does not activate a stub" do

        before(:each) { allow(stub_activator_response).to receive(:empty?).and_return(true) }

        it "processes an error response via the response pipeline" do
          expect(response_pipeline).to receive(:process).with(HttpStub::Models::Response::ERROR)

          subject
        end

      end

    end

  end

end
