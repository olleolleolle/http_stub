describe HttpStub::Configurer::Request::StubActivatorPayloadBuilder do

  include_context "stub payload builder arguments"

  let(:stub_payload) { { "stub_payload_key" => "stub payload value" } }
  let(:stub_builder) { instance_double(HttpStub::Configurer::Request::StubPayloadBuilder, build: stub_payload) }

  let(:builder) { HttpStub::Configurer::Request::StubActivatorPayloadBuilder.new }

  before(:example) do
    allow(HttpStub::Configurer::Request::StubPayloadBuilder).to receive(:new).and_return(stub_builder)
  end

  describe "#match_requests" do

    it "delegates to a stub payload builder" do
      expect(stub_builder).to receive(:match_requests).with(uri, request_options)

      builder.match_requests(uri, request_options)
    end

  end

  describe "#respond_with" do

    it "delegates to a stub payload builder" do
      expect(stub_builder).to receive(:respond_with).with(response_options)

      builder.respond_with(response_options)
    end

  end

  describe "#and_add_stub" do

    let(:trigger_builder) { instance_double(HttpStub::Configurer::Request::StubPayloadBuilder) }

    it "delegates to a stub payload builder" do
      expect(stub_builder).to receive(:and_add_stub).with(trigger_builder)

      builder.and_add_stub(trigger_builder)
    end

  end

  describe "#and_add_stubs" do

    let(:trigger_builders) { (1..3).map { instance_double(HttpStub::Configurer::Request::StubPayloadBuilder) } }

    it "delegates to a stub payload builder" do
      expect(stub_builder).to receive(:and_add_stubs).with(trigger_builders)

      builder.and_add_stubs(trigger_builders)
    end

  end

  describe "#build" do

    subject { builder.build }

    context "when a path on which the activator is activated is established" do

      let(:activation_uri) { "http://some/activation/uri" }

      before(:example) { builder.on(activation_uri) }

      it "returns a payload that includes the activation uri" do
        expect(subject).to include(activation_uri: activation_uri)
      end

      it "builds a stub payload" do
        expect(stub_builder).to receive(:build)

        subject
      end

      it "returns a payload that includes the stub payload" do
        expect(subject).to include(stub_payload)
      end

    end

  end

end
